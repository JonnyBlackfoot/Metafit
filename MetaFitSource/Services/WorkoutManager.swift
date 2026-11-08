import Foundation
import Combine

class WorkoutManager: ObservableObject {
    static let shared = WorkoutManager()

    @Published var currentWorkout: Workout?
    @Published var workoutHistory: [Workout] = []
    @Published var isWorkoutActive = false
    @Published var elapsedTime: TimeInterval = 0

    private var timer: Timer?
    private let storage = StorageManager.shared
    let healthKit = HealthKitManager.shared

    private init() {
        workoutHistory = storage.loadWorkouts()
    }

    func startWorkout() {
        let workout = Workout()
        currentWorkout = workout
        isWorkoutActive = true
        healthKit.startWorkoutSession()
        startTimer()
    }

    func addExercise(_ exercise: Exercise) {
        guard var workout = currentWorkout else { return }
        let workoutExercise = WorkoutExercise(exercise: exercise)
        workout.exercises.append(workoutExercise)
        currentWorkout = workout
    }

    func addSet(to exerciseIndex: Int) {
        guard var workout = currentWorkout,
              exerciseIndex < workout.exercises.count else { return }

        let previousSet = workout.exercises[exerciseIndex].sets.last
        let newSet = ExerciseSet(
            reps: previousSet?.reps ?? 10,
            weight: previousSet?.weight ?? 0
        )
        workout.exercises[exerciseIndex].sets.append(newSet)
        currentWorkout = workout
    }

    func updateSet(exerciseIndex: Int, setIndex: Int, reps: Int? = nil, weight: Double? = nil) {
        guard var workout = currentWorkout,
              exerciseIndex < workout.exercises.count,
              setIndex < workout.exercises[exerciseIndex].sets.count else { return }

        if let reps = reps {
            workout.exercises[exerciseIndex].sets[setIndex].reps = reps
        }
        if let weight = weight {
            workout.exercises[exerciseIndex].sets[setIndex].weight = weight
        }
        currentWorkout = workout
    }

    func completeSet(exerciseIndex: Int, setIndex: Int) {
        guard var workout = currentWorkout,
              exerciseIndex < workout.exercises.count,
              setIndex < workout.exercises[exerciseIndex].sets.count else { return }

        workout.exercises[exerciseIndex].sets[setIndex].isCompleted = true
        currentWorkout = workout
    }

    func removeExercise(at index: Int) {
        guard var workout = currentWorkout else { return }
        workout.exercises.remove(at: index)
        currentWorkout = workout
    }

    func removeSet(exerciseIndex: Int, setIndex: Int) {
        guard var workout = currentWorkout,
              exerciseIndex < workout.exercises.count else { return }
        workout.exercises[exerciseIndex].sets.remove(at: setIndex)
        currentWorkout = workout
    }

    func finishWorkout() {
        guard var workout = currentWorkout else { return }
        workout.endDate = Date()
        workout.isActive = false

        storage.saveWorkout(workout)
        workoutHistory = storage.loadWorkouts()

        healthKit.endWorkoutSession()
        stopTimer()

        currentWorkout = nil
        isWorkoutActive = false
        elapsedTime = 0
    }

    func cancelWorkout() {
        healthKit.endWorkoutSession()
        stopTimer()
        currentWorkout = nil
        isWorkoutActive = false
        elapsedTime = 0
    }

    func deleteWorkout(id: UUID) {
        storage.deleteWorkout(id: id)
        workoutHistory = storage.loadWorkouts()
    }

    var todaysWorkout: Workout? {
        workoutHistory.first { Calendar.current.isDateInToday($0.startDate) }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let workout = self.currentWorkout else { return }
            self.elapsedTime = workout.duration
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
