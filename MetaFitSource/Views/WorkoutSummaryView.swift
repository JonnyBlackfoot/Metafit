import SwiftUI

struct WorkoutSummaryView: View {
    let workout: Workout

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    Text("Workout Complete!")
                        .font(.headline)
                    Text(workout.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)

                // Stats grid
                HStack(spacing: 8) {
                    SummaryStatView(
                        icon: "clock",
                        value: workout.formattedDuration,
                        label: "Duration"
                    )
                    SummaryStatView(
                        icon: "scalemass",
                        value: workout.formattedVolume,
                        label: "Volume"
                    )
                }

                HStack(spacing: 8) {
                    SummaryStatView(
                        icon: "dumbbell",
                        value: "\(workout.exercises.count)",
                        label: "Exercises"
                    )
                    SummaryStatView(
                        icon: "checkmark.circle",
                        value: "\(workout.totalSetsCompleted)",
                        label: "Sets"
                    )
                }

                // Exercise breakdown
                VStack(alignment: .leading, spacing: 6) {
                    Text("Exercises")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(workout.exercises) { exercise in
                        HStack {
                            Text(exercise.exercise.name)
                                .font(.caption2)
                                .lineLimit(1)
                            Spacer()
                            Text("\(exercise.completedSets) sets")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Summary")
    }
}

struct SummaryStatView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.green)
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}
