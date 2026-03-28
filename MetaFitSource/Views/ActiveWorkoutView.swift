import SwiftUI

struct ActiveWorkoutView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    @ObservedObject var healthKit = HealthKitManager.shared
    @State private var showExercisePicker = false
    @State private var showFinishConfirm = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                workoutStatsBar

                if let workout = workoutManager.currentWorkout {
                    exercisesList(workout)
                }

                addExerciseButton

                finishButton
            }
            .padding(.horizontal)
        }
        .navigationTitle("Workout")
        .navigationBarBackButtonHidden(workoutManager.isWorkoutActive)
        .onAppear {
            if !workoutManager.isWorkoutActive {
                workoutManager.startWorkout()
            }
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView { exercise in
                workoutManager.addExercise(exercise)
                // Auto-add first set
                if let index = workoutManager.currentWorkout?.exercises.count {
                    workoutManager.addSet(to: index - 1)
                }
            }
        }
        .confirmationDialog("Finish Workout?", isPresented: $showFinishConfirm) {
            Button("Finish", role: .none) {
                workoutManager.finishWorkout()
                dismiss()
            }
            Button("Cancel Workout", role: .destructive) {
                workoutManager.cancelWorkout()
                dismiss()
            }
        }
    }

    private var workoutStatsBar: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text(formattedElapsedTime)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                Text("Duration")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }

            if healthKit.heartRate > 0 {
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                        Text("\(Int(healthKit.heartRate))")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                    }
                    Text("BPM")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 2) {
                Text("\(workoutManager.currentWorkout?.totalSetsCompleted ?? 0)")
                    .font(.body)
                    .fontWeight(.medium)
                Text("Sets")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }

    private func exercisesList(_ workout: Workout) -> some View {
        ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { exerciseIndex, workoutExercise in
            NavigationLink {
                LogSetView(exerciseIndex: exerciseIndex)
            } label: {
                exerciseRow(workoutExercise)
            }
        }
    }

    private func exerciseRow(_ workoutExercise: WorkoutExercise) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(workoutExercise.exercise.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text("\(workoutExercise.completedSets)/\(workoutExercise.sets.count) sets")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: workoutExercise.completedSets == workoutExercise.sets.count && !workoutExercise.sets.isEmpty
                ? "checkmark.circle.fill" : "chevron.right")
                .foregroundStyle(workoutExercise.completedSets == workoutExercise.sets.count && !workoutExercise.sets.isEmpty
                    ? .green : .secondary)
                .font(.caption)
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }

    private var addExerciseButton: some View {
        Button {
            showExercisePicker = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Exercise")
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
    }

    private var finishButton: some View {
        Button {
            showFinishConfirm = true
        } label: {
            HStack {
                Image(systemName: "flag.checkered")
                Text("Finish")
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
    }

    private var formattedElapsedTime: String {
        let minutes = Int(workoutManager.elapsedTime) / 60
        let seconds = Int(workoutManager.elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
