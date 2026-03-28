import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var workoutVM = WorkoutViewModel()
    @StateObject private var healthKit = HealthKitManager.shared
    @State private var activitySummary: ActivityData?
    @State private var navigateToGenerator = false
    @State private var navigateToHistory = false
    @State private var navigateToGallery = false
    @State private var navigateToSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    activityRings
                    quickStartSection
                    navigationSection
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("MetaFit")
            .task { await loadActivity() }
            .navigationDestination(isPresented: $navigateToGenerator) {
                WorkoutGeneratorView()
            }
            .navigationDestination(isPresented: $navigateToHistory) {
                WorkoutHistoryView()
            }
            .navigationDestination(isPresented: $navigateToGallery) {
                GlassesGalleryView()
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $workoutVM.isWorkoutActive) {
                ActiveWorkoutView(viewModel: workoutVM)
            }
        }
    }

    // MARK: - Activity rings

    private var activityRings: some View {
        VStack(spacing: 6) {
            HStack(spacing: 16) {
                RingView(
                    progress: activitySummary?.moveProgress ?? 0,
                    color: .red,
                    icon: "flame.fill",
                    value: activitySummary?.moveCalories ?? 0,
                    unit: "cal"
                )
                RingView(
                    progress: activitySummary?.exerciseProgress ?? 0,
                    color: .green,
                    icon: "figure.run",
                    value: activitySummary?.exerciseMinutes ?? 0,
                    unit: "min"
                )
                RingView(
                    progress: activitySummary?.standProgress ?? 0,
                    color: .cyan,
                    icon: "figure.stand",
                    value: activitySummary?.standHours ?? 0,
                    unit: "hrs"
                )
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Quick start

    private var quickStartSection: some View {
        Button {
            navigateToGenerator = true
        } label: {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Workout")
                        .font(.caption.weight(.semibold))
                    Text("Generate a new plan")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(Color.green.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Navigation

    private var navigationSection: some View {
        VStack(spacing: 6) {
            NavigationRow(
                icon: "clock.arrow.circlepath",
                title: "History",
                color: .blue
            ) {
                navigateToHistory = true
            }

            NavigationRow(
                icon: "camera.fill",
                title: "Glasses Photos",
                color: .purple
            ) {
                navigateToGallery = true
            }

            NavigationRow(
                icon: "gearshape.fill",
                title: "Settings",
                color: .gray
            ) {
                navigateToSettings = true
            }
        }
    }

    // MARK: - Data loading

    private func loadActivity() async {
        do {
            try await healthKit.requestAuthorization()
        } catch { /* continue without HK */ }

        if let summary = await healthKit.fetchTodayActivitySummary() {
            let moveUnit = HKUnit.kilocalorie()
            let exerciseUnit = HKUnit.minute()
            let standUnit = HKUnit.count()

            activitySummary = ActivityData(
                moveCalories: summary.activeEnergyBurned.doubleValue(for: moveUnit),
                moveGoal: summary.activeEnergyBurnedGoal.doubleValue(for: moveUnit),
                exerciseMinutes: summary.appleExerciseTime.doubleValue(for: exerciseUnit),
                exerciseGoal: summary.appleExerciseTimeGoal.doubleValue(for: exerciseUnit),
                standHours: summary.appleStandHours.doubleValue(for: standUnit),
                standGoal: summary.appleStandHoursGoal.doubleValue(for: standUnit)
            )
        }
    }
}

// MARK: - Activity data

import HealthKit

struct ActivityData {
    let moveCalories: Double
    let moveGoal: Double
    let exerciseMinutes: Double
    let exerciseGoal: Double
    let standHours: Double
    let standGoal: Double

    var moveProgress: Double { moveGoal > 0 ? min(moveCalories / moveGoal, 1) : 0 }
    var exerciseProgress: Double { exerciseGoal > 0 ? min(exerciseMinutes / exerciseGoal, 1) : 0 }
    var standProgress: Double { standGoal > 0 ? min(standHours / standGoal, 1) : 0 }
}

// MARK: - Ring view

struct RingView: View {
    let progress: Double
    let color: Color
    let icon: String
    let value: Double
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
            }
            .frame(width: 40, height: 40)

            Text(String(format: "%.0f", value))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
            Text(unit)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Navigation row

struct NavigationRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 20)
                Text(title)
                    .font(.caption)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            .background(Color(.darkGray).opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
