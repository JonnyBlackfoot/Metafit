import SwiftUI

struct LogSetView: View {
    let exerciseIndex: Int
    @ObservedObject var workoutManager = WorkoutManager.shared
    @State private var showRestTimer = false

    private var workoutExercise: WorkoutExercise? {
        guard let workout = workoutManager.currentWorkout,
              exerciseIndex < workout.exercises.count else { return nil }
        return workout.exercises[exerciseIndex]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if let exercise = workoutExercise {
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, exerciseSet in
                        setRow(setIndex: setIndex, exerciseSet: exerciseSet)
                    }

                    addSetButton

                    restTimerButton
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(workoutExercise?.exercise.name ?? "Exercise")
        .sheet(isPresented: $showRestTimer) {
            RestTimerView()
        }
    }

    private func setRow(setIndex: Int, exerciseSet: ExerciseSet) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text("Set \(setIndex + 1)")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                if exerciseSet.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }

            if !exerciseSet.isCompleted {
                HStack(spacing: 8) {
                    // Reps stepper
                    VStack(spacing: 2) {
                        Text("Reps")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Button {
                                let newReps = max(1, exerciseSet.reps - 1)
                                workoutManager.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, reps: newReps)
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)

                            Text("\(exerciseSet.reps)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .frame(minWidth: 24)

                            Button {
                                workoutManager.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, reps: exerciseSet.reps + 1)
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Divider()
                        .frame(height: 30)

                    // Weight stepper
                    VStack(spacing: 2) {
                        Text("Weight")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Button {
                                let newWeight = max(0, exerciseSet.weight - 5)
                                workoutManager.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: newWeight)
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)

                            Text("\(Int(exerciseSet.weight))")
                                .font(.body)
                                .fontWeight(.semibold)
                                .frame(minWidth: 28)

                            Button {
                                workoutManager.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: exerciseSet.weight + 5)
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    workoutManager.completeSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
                    showRestTimer = true
                } label: {
                    Text("Complete Set")
                        .font(.caption2)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            } else {
                HStack {
                    Text("\(exerciseSet.reps) reps")
                        .font(.caption)
                    Text("@")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(exerciseSet.weight)) lbs")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }

    private var addSetButton: some View {
        Button {
            workoutManager.addSet(to: exerciseIndex)
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Add Set")
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
    }

    private var restTimerButton: some View {
        Button {
            showRestTimer = true
        } label: {
            HStack {
                Image(systemName: "timer")
                Text("Rest Timer")
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
    }
}
