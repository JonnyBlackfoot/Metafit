import Foundation

struct Workout: Identifiable, Codable {
    let id: UUID
    var exercises: [WorkoutExercise]
    let startDate: Date
    var endDate: Date?
    var isActive: Bool

    init(id: UUID = UUID(), exercises: [WorkoutExercise] = [], startDate: Date = Date(), endDate: Date? = nil, isActive: Bool = true) {
        self.id = id
        self.exercises = exercises
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
    }

    var duration: TimeInterval {
        let end = endDate ?? Date()
        return end.timeIntervalSince(startDate)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
        return "\(minutes)m \(seconds)s"
    }

    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }

    var formattedVolume: String {
        if totalVolume >= 1000 {
            return String(format: "%.1fk lbs", totalVolume / 1000)
        }
        return String(format: "%.0f lbs", totalVolume)
    }

    var totalSetsCompleted: Int {
        exercises.reduce(0) { $0 + $1.completedSets }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: startDate)
    }
}
