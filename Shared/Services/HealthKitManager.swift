import Foundation
import HealthKit
import Combine

@MainActor
final class HealthKitManager: NSObject, ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    #if os(watchOS)
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    #endif

    @Published var isAuthorized = false
    @Published var isSessionActive = false
    @Published var heartRate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var elapsedSeconds: Int = 0

    private var heartRateSamples: [Double] = []
    private var elapsedTimer: Timer?

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let typesToShare: Set<HKSampleType> = [HKObjectType.workoutType()]

        var typesToRead = Set<HKObjectType>()
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            typesToRead.insert(heartRate)
        }
        if let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            typesToRead.insert(activeEnergy)
        }
        if let basalEnergy = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) {
            typesToRead.insert(basalEnergy)
        }

        #if os(iOS)
        typesToRead.insert(HKObjectType.activitySummaryType())
        #endif

        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        isAuthorized = true
    }

    // MARK: - Workout session (watchOS only)

    #if os(watchOS)
    func startWorkoutSession(name: String) async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        config.locationType = .indoor

        let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
        let builder = session.associatedWorkoutBuilder()

        builder.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: config
        )

        session.delegate = self
        builder.delegate = self

        self.workoutSession = session
        self.workoutBuilder = builder

        session.startActivity(with: Date())
        try await builder.beginCollection(at: Date())

        isSessionActive = true
        heartRateSamples = []
        elapsedSeconds = 0
        startElapsedTimer()
    }

    func pauseWorkout() {
        workoutSession?.pause()
    }

    func resumeWorkout() {
        workoutSession?.resume()
    }

    func endWorkoutSession() async throws -> WorkoutRecord? {
        guard let session = workoutSession,
              let builder = workoutBuilder else { return nil }

        session.end()
        try await builder.endCollection(at: Date())
        try await builder.finishWorkout()

        stopElapsedTimer()
        isSessionActive = false

        let avgHR = heartRateSamples.isEmpty ? nil : heartRateSamples.reduce(0, +) / Double(heartRateSamples.count)
        let maxHR = heartRateSamples.max()

        let record = WorkoutRecord(
            name: "Strength Workout",
            startedAt: session.startDate ?? Date(),
            completedAt: Date(),
            durationSeconds: elapsedSeconds,
            caloriesBurned: activeCalories,
            averageHeartRate: avgHR,
            maxHeartRate: maxHR
        )

        self.workoutSession = nil
        self.workoutBuilder = nil

        return record
    }
    #endif

    // MARK: - Activity summary

    func fetchTodayActivitySummary() async -> HKActivitySummary? {
        #if os(watchOS)
        // Activity summary queries are not needed for this watch-first dashboard path.
        return nil
        #else
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let components = calendar.dateComponents([.year, .month, .day], from: startOfDay)

        let predicate = HKQuery.predicateForActivitySummary(with: components)

        return await withCheckedContinuation { continuation in
            let query = HKActivitySummaryQuery(predicate: predicate) { _, summaries, _ in
                continuation.resume(returning: summaries?.first)
            }
            healthStore.execute(query)
        }
        #endif
    }

    // MARK: - Elapsed timer

    private func startElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }

    // MARK: - Heart rate processing

    private func processHeartRateSamples(_ samples: [HKSample]) {
        guard let quantitySamples = samples as? [HKQuantitySample] else { return }
        let unit = HKUnit.count().unitDivided(by: .minute())

        for sample in quantitySamples {
            let value = sample.quantity.doubleValue(for: unit)
            heartRateSamples.append(value)
            heartRate = value
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

#if os(watchOS)
extension HealthKitManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        Task { @MainActor in
            switch toState {
            case .running:
                isSessionActive = true
            case .paused, .stopped, .ended:
                if toState == .stopped || toState == .ended {
                    isSessionActive = false
                }
            default:
                break
            }
        }
    }

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            isSessionActive = false
        }
    }
}
#endif

// MARK: - HKLiveWorkoutBuilderDelegate

#if os(watchOS)
extension HealthKitManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }

            let statistics = workoutBuilder.statistics(for: quantityType)

            Task { @MainActor in
                switch quantityType {
                case HKQuantityType(.heartRate):
                    let unit = HKUnit.count().unitDivided(by: .minute())
                    if let value = statistics?.mostRecentQuantity()?.doubleValue(for: unit) {
                        heartRate = value
                        heartRateSamples.append(value)
                    }
                case HKQuantityType(.activeEnergyBurned):
                    let unit = HKUnit.kilocalorie()
                    if let value = statistics?.sumQuantity()?.doubleValue(for: unit) {
                        activeCalories = value
                    }
                default:
                    break
                }
            }
        }
    }
}
#endif
