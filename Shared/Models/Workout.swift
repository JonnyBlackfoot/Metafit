import Foundation
import SwiftData

// MARK: - Value types for AI generation and in-session use

enum MuscleGroup: String, Codable, CaseIterable, Identifiable, Hashable {
    case chest, back, shoulders, biceps, triceps, forearms
    case quads, hamstrings, glutes, calves
    case abs, obliques
    case fullBody = "full_body"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullBody: return "Full Body"
        default: return rawValue.capitalized
        }
    }
}

enum Equipment: String, Codable, CaseIterable, Identifiable, Hashable {
    case barbell, dumbbell, kettlebell, cable, machine
    case bodyweight, resistanceBand = "resistance_band"
    case pullUpBar = "pull_up_bar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .resistanceBand: return "Resistance Band"
        case .pullUpBar: return "Pull-Up Bar"
        default: return rawValue.capitalized
        }
    }
}

enum Difficulty: String, Codable, CaseIterable, Identifiable, Hashable {
    case beginner, intermediate, advanced

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

struct ExerciseSet: Codable, Identifiable, Hashable {
    var id = UUID()
    var reps: Int
    var weight: Double?
    var durationSeconds: Int?
    var isCompleted: Bool = false
    var completedAt: Date?
}

struct Exercise: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var muscleGroup: MuscleGroup
    var equipment: Equipment
    var sets: [ExerciseSet]
    var restSeconds: Int
    var notes: String?
}

struct GeneratedWorkout: Codable, Identifiable {
    var id = UUID()
    var name: String
    var exercises: [Exercise]
    var estimatedMinutes: Int
    var difficulty: Difficulty
    var targetMuscles: [MuscleGroup]
    var createdAt: Date = Date()
}

// MARK: - SwiftData persistent record

@Model
final class WorkoutRecord {
    var id: UUID
    var name: String
    var startedAt: Date
    var completedAt: Date?
    var durationSeconds: Int
    var totalSets: Int
    var totalReps: Int
    var caloriesBurned: Double?
    var averageHeartRate: Double?
    var maxHeartRate: Double?
    var difficulty: String
    var targetMuscles: [String]
    var exercisesJSON: Data
    var isAIGenerated: Bool

    init(
        name: String,
        startedAt: Date,
        completedAt: Date? = nil,
        durationSeconds: Int = 0,
        totalSets: Int = 0,
        totalReps: Int = 0,
        caloriesBurned: Double? = nil,
        averageHeartRate: Double? = nil,
        maxHeartRate: Double? = nil,
        difficulty: String = "intermediate",
        targetMuscles: [String] = [],
        exercises: [Exercise] = [],
        isAIGenerated: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.caloriesBurned = caloriesBurned
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.difficulty = difficulty
        self.targetMuscles = targetMuscles
        self.exercisesJSON = (try? JSONEncoder().encode(exercises)) ?? Data()
        self.isAIGenerated = isAIGenerated
    }

    var exercises: [Exercise] {
        (try? JSONDecoder().decode([Exercise].self, from: exercisesJSON)) ?? []
    }
}
