import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: ExerciseCategory
    let isBodyweight: Bool

    init(id: UUID = UUID(), name: String, category: ExerciseCategory, isBodyweight: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.isBodyweight = isBodyweight
    }
}

struct ExerciseSet: Identifiable, Codable {
    let id: UUID
    var reps: Int
    var weight: Double
    var isCompleted: Bool

    init(id: UUID = UUID(), reps: Int = 10, weight: Double = 0, isCompleted: Bool = false) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.isCompleted = isCompleted
    }
}

struct WorkoutExercise: Identifiable, Codable {
    let id: UUID
    let exercise: Exercise
    var sets: [ExerciseSet]

    init(id: UUID = UUID(), exercise: Exercise, sets: [ExerciseSet] = []) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }

    var totalVolume: Double {
        sets.filter(\.isCompleted).reduce(0) { $0 + Double($1.reps) * $1.weight }
    }

    var completedSets: Int {
        sets.filter(\.isCompleted).count
    }
}
