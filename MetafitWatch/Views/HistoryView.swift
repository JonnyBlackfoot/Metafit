import SwiftUI

struct HistoryView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared

    var body: some View {
        Group {
            if workoutManager.workoutHistory.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No workouts yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Start your first workout!")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(sortedWorkouts) { workout in
                        NavigationLink {
                            WorkoutSummaryView(workout: workout)
                        } label: {
                            workoutRow(workout)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let workout = sortedWorkouts[index]
                            workoutManager.deleteWorkout(id: workout.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }

    private var sortedWorkouts: [Workout] {
        workoutManager.workoutHistory.sorted { $0.startDate > $1.startDate }
    }

    private func workoutRow(_ workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.dayOfWeek)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text(workout.formattedDuration)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(workout.formattedDate)
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack {
                Label("\(workout.exercises.count)", systemImage: "dumbbell")
                Spacer()
                Label("\(workout.totalSetsCompleted)", systemImage: "checkmark.circle")
                Spacer()
                Text(workout.formattedVolume)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
