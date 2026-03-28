import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @StateObject private var healthKit = HealthKitManager.shared
    @Environment(\.modelContext) private var modelContext
    @State private var showSummary = false

    var body: some View {
        if showSummary {
            WorkoutSummaryView(
                viewModel: viewModel,
                healthKit: healthKit,
                onDismiss: { showSummary = false }
            )
        } else {
            workoutContent
                .task { await startHealthKitSession() }
        }
    }

    private var workoutContent: some View {
        TabView {
            exerciseTab
            metricsTab
            controlsTab
        }
        .tabViewStyle(.verticalPage)
    }

    // MARK: - Exercise tab (main)

    private var exerciseTab: some View {
        ScrollView {
            VStack(spacing: 8) {
                if viewModel.isResting {
                    restOverlay
                } else if let exercise = viewModel.currentExercise {
                    exerciseHeader(exercise)
                    setsList(exercise)
                    completeSetButton
                } else {
                    Text("Workout Complete")
                        .font(.headline)
                }

                progressBar
            }
            .padding(.horizontal, 4)
        }
    }

    private func exerciseHeader(_ exercise: Exercise) -> some View {
        VStack(spacing: 4) {
            Text(exercise.name)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Set \(viewModel.currentSetIndex + 1) of \(exercise.sets.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func setsList(_ exercise: Exercise) -> some View {
        VStack(spacing: 4) {
            ForEach(Array(exercise.sets.enumerated()), id: \.offset) { index, exerciseSet in
                HStack {
                    Image(systemName: exerciseSet.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(exerciseSet.isCompleted ? .green : .gray)

                    Text("\(exerciseSet.reps) reps")
                        .font(.caption)

                    Spacer()

                    if index == viewModel.currentSetIndex && !exerciseSet.isCompleted {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.green)
                            .font(.caption2)
                    }
                }
                .opacity(index < viewModel.currentSetIndex ? 0.5 : 1)
            }
        }
        .padding(.horizontal, 8)
    }

    private var completeSetButton: some View {
        Button {
            #if os(watchOS)
            WKInterfaceDevice.current().play(.click)
            #endif
            viewModel.completeSet()
        } label: {
            Label("Done", systemImage: "checkmark")
                .frame(maxWidth: .infinity)
                .font(.body.weight(.semibold))
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
    }

    private var restOverlay: some View {
        VStack(spacing: 8) {
            Text("REST")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("\(viewModel.restTimeRemaining)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
                .monospacedDigit()

            Text("seconds")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button("Skip") {
                viewModel.skipRest()
            }
            .font(.caption)
        }
    }

    private var progressBar: some View {
        VStack(spacing: 2) {
            ProgressView(
                value: Double(viewModel.totalSetsCompleted),
                total: Double(max(viewModel.totalSets, 1))
            )
            .tint(.green)

            Text("\(viewModel.totalSetsCompleted)/\(viewModel.totalSets) sets")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    // MARK: - Metrics tab

    private var metricsTab: some View {
        VStack(spacing: 12) {
            MetricRing(
                value: healthKit.heartRate,
                label: "BPM",
                icon: "heart.fill",
                color: .red
            )

            HStack(spacing: 16) {
                MetricBox(
                    value: formatDuration(healthKit.elapsedSeconds),
                    label: "Time",
                    icon: "clock"
                )

                MetricBox(
                    value: String(format: "%.0f", healthKit.activeCalories),
                    label: "Cal",
                    icon: "flame.fill"
                )
            }
        }
        .padding()
    }

    // MARK: - Controls tab

    private var controlsTab: some View {
        VStack(spacing: 12) {
            Button {
                Task { await endWorkout() }
            } label: {
                Label("End Workout", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

            if healthKit.isSessionActive {
                Button {
                    healthKit.pauseWorkout()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    // MARK: - Actions

    private func startHealthKitSession() async {
        do {
            try await healthKit.requestAuthorization()
            #if os(watchOS)
            try await healthKit.startWorkoutSession(
                name: viewModel.activeWorkout?.name ?? "Workout"
            )
            #endif
        } catch {
            // HealthKit unavailable (e.g. simulator); continue with workout tracking
        }
    }

    private func endWorkout() async {
        #if os(watchOS)
        if let record = try? await healthKit.endWorkoutSession() {
            var finalRecord = record
            if let workout = viewModel.activeWorkout {
                finalRecord = WorkoutRecord(
                    name: workout.name,
                    startedAt: record.startedAt,
                    completedAt: Date(),
                    durationSeconds: healthKit.elapsedSeconds,
                    totalSets: viewModel.totalSetsCompleted,
                    totalReps: viewModel.activeWorkout?.exercises
                        .flatMap(\.sets)
                        .filter(\.isCompleted)
                        .reduce(0) { $0 + $1.reps } ?? 0,
                    caloriesBurned: healthKit.activeCalories,
                    averageHeartRate: record.averageHeartRate,
                    maxHeartRate: record.maxHeartRate,
                    difficulty: workout.difficulty.rawValue,
                    targetMuscles: workout.targetMuscles.map(\.rawValue),
                    exercises: workout.exercises,
                    isAIGenerated: true
                )
            }
            modelContext.insert(finalRecord)
            try? modelContext.save()
        }
        #endif

        viewModel.finishWorkout()
        showSummary = true
    }

    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Metric components

struct MetricRing: View {
    let value: Double
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)

            Text(String(format: "%.0f", value))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct MetricBox: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Workout summary

struct WorkoutSummaryView: View {
    let viewModel: WorkoutViewModel
    let healthKit: HealthKitManager
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)

                Text("Workout Complete")
                    .font(.headline)

                Divider()

                summaryGrid

                Button("Done") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.horizontal, 4)
        }
    }

    private var summaryGrid: some View {
        VStack(spacing: 8) {
            SummaryRow(icon: "clock", label: "Duration", value: formatDuration(healthKit.elapsedSeconds))
            SummaryRow(icon: "flame.fill", label: "Calories", value: String(format: "%.0f kcal", healthKit.activeCalories))
            SummaryRow(icon: "heart.fill", label: "Avg HR", value: String(format: "%.0f bpm", healthKit.heartRate))
            SummaryRow(icon: "checkmark.circle", label: "Sets", value: "\(viewModel.totalSetsCompleted)/\(viewModel.totalSets)")
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(.green)
            Text(label)
                .font(.caption)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
    }
}
