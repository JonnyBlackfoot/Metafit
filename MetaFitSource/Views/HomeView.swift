import SwiftUI

struct HomeView: View {
    @ObservedObject var workoutManager = WorkoutManager.shared
    @State private var showingHistory = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection

                    if let todaysWorkout = workoutManager.todaysWorkout {
                        todaysWorkoutCard(todaysWorkout)
                    }

                    startWorkoutButton

                    NavigationLink {
                        HistoryView()
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Workout History")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)

                    statsSection
                }
                .padding(.horizontal)
            }
            .navigationTitle("MetaFit")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(currentDayString)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func todaysWorkoutCard(_ workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Today's Workout", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)

            HStack {
                VStack(alignment: .leading) {
                    Text("\(workout.exercises.count) exercises")
                        .font(.caption2)
                    Text(workout.formattedDuration)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(workout.formattedVolume)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var startWorkoutButton: some View {
        NavigationLink {
            ActiveWorkoutView()
        } label: {
            HStack {
                Image(systemName: "flame.fill")
                Text(workoutManager.todaysWorkout != nil ? "New Workout" : "Start Workout")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                StatBox(title: "Workouts", value: "\(thisWeekWorkouts.count)")
                StatBox(title: "Volume", value: thisWeekVolume)
            }
        }
    }

    private var thisWeekWorkouts: [Workout] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return workoutManager.workoutHistory.filter { $0.startDate >= startOfWeek }
    }

    private var thisWeekVolume: String {
        let total = thisWeekWorkouts.reduce(0) { $0 + $1.totalVolume }
        if total >= 1000 {
            return String(format: "%.1fk", total / 1000)
        }
        return String(format: "%.0f", total)
    }

    private var currentDayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}
