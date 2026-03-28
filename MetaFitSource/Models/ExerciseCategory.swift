import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .shoulders: return "figure.arms.open"
        case .arms: return "figure.curling"
        case .legs: return "figure.walk"
        case .core: return "figure.core.training"
        case .cardio: return "figure.run"
        }
    }
}

struct ExerciseLibrary {
    static let exercises: [Exercise] = [
        // Chest
        Exercise(name: "Bench Press", category: .chest),
        Exercise(name: "Incline Bench Press", category: .chest),
        Exercise(name: "Dumbbell Fly", category: .chest),
        Exercise(name: "Cable Crossover", category: .chest),
        Exercise(name: "Push-Up", category: .chest, isBodyweight: true),
        Exercise(name: "Chest Press Machine", category: .chest),

        // Back
        Exercise(name: "Deadlift", category: .back),
        Exercise(name: "Barbell Row", category: .back),
        Exercise(name: "Lat Pulldown", category: .back),
        Exercise(name: "Seated Cable Row", category: .back),
        Exercise(name: "Pull-Up", category: .back, isBodyweight: true),
        Exercise(name: "T-Bar Row", category: .back),

        // Shoulders
        Exercise(name: "Overhead Press", category: .shoulders),
        Exercise(name: "Lateral Raise", category: .shoulders),
        Exercise(name: "Front Raise", category: .shoulders),
        Exercise(name: "Face Pull", category: .shoulders),
        Exercise(name: "Arnold Press", category: .shoulders),
        Exercise(name: "Reverse Fly", category: .shoulders),

        // Arms
        Exercise(name: "Barbell Curl", category: .arms),
        Exercise(name: "Dumbbell Curl", category: .arms),
        Exercise(name: "Hammer Curl", category: .arms),
        Exercise(name: "Tricep Pushdown", category: .arms),
        Exercise(name: "Skull Crusher", category: .arms),
        Exercise(name: "Tricep Dip", category: .arms, isBodyweight: true),

        // Legs
        Exercise(name: "Squat", category: .legs),
        Exercise(name: "Leg Press", category: .legs),
        Exercise(name: "Romanian Deadlift", category: .legs),
        Exercise(name: "Leg Extension", category: .legs),
        Exercise(name: "Leg Curl", category: .legs),
        Exercise(name: "Calf Raise", category: .legs),
        Exercise(name: "Bulgarian Split Squat", category: .legs),
        Exercise(name: "Hip Thrust", category: .legs),

        // Core
        Exercise(name: "Plank", category: .core, isBodyweight: true),
        Exercise(name: "Cable Crunch", category: .core),
        Exercise(name: "Hanging Leg Raise", category: .core, isBodyweight: true),
        Exercise(name: "Russian Twist", category: .core),
        Exercise(name: "Ab Wheel Rollout", category: .core),

        // Cardio
        Exercise(name: "Treadmill", category: .cardio),
        Exercise(name: "Stationary Bike", category: .cardio),
        Exercise(name: "Rowing Machine", category: .cardio),
        Exercise(name: "Elliptical", category: .cardio),
        Exercise(name: "Stair Climber", category: .cardio),
    ]

    static func exercises(for category: ExerciseCategory) -> [Exercise] {
        exercises.filter { $0.category == category }
    }
}
