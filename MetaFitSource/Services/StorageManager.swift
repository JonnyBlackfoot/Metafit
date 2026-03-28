import Foundation

class StorageManager {
    static let shared = StorageManager()

    private let workoutsKey = "metafit_workouts"
    private let defaults = UserDefaults.standard

    private init() {}

    func saveWorkouts(_ workouts: [Workout]) {
        guard let data = try? JSONEncoder().encode(workouts) else { return }
        defaults.set(data, forKey: workoutsKey)
    }

    func loadWorkouts() -> [Workout] {
        guard let data = defaults.data(forKey: workoutsKey),
              let workouts = try? JSONDecoder().decode([Workout].self, from: data) else {
            return []
        }
        return workouts
    }

    func saveWorkout(_ workout: Workout) {
        var workouts = loadWorkouts()
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
        } else {
            workouts.append(workout)
        }
        saveWorkouts(workouts)
    }

    func deleteWorkout(id: UUID) {
        var workouts = loadWorkouts()
        workouts.removeAll { $0.id == id }
        saveWorkouts(workouts)
    }
}
