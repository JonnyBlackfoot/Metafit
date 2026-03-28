import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Query(sort: \WorkoutRecord.startedAt, order: .reverse) private var workouts: [WorkoutRecord]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if workouts.isEmpty {
                emptyState
            } else {
                workoutList
            }
        }
        .navigationTitle("History")
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No workouts yet")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Generate and complete a workout to see it here.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var workoutList: some View {
        List {
            ForEach(workouts) { record in
                WorkoutHistoryRow(record: record)
            }
            .onDelete(perform: deleteWorkouts)
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(workouts[index])
        }
        try? modelContext.save()
    }
}

struct WorkoutHistoryRow: View {
    let record: WorkoutRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(record.name)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)

                Spacer()

                if record.isAIGenerated {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            HStack(spacing: 8) {
                Label(formatDuration(record.durationSeconds), systemImage: "clock")
                if let cal = record.caloriesBurned {
                    Label(String(format: "%.0f cal", cal), systemImage: "flame.fill")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Text(record.startedAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
