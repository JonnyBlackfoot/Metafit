import Foundation
import SwiftUI
import Combine
#if os(watchOS)
import WatchKit
#endif

@MainActor
final class WorkoutViewModel: ObservableObject {
    // MARK: - Generator inputs
    @Published var selectedMuscles: Set<MuscleGroup> = [.chest]
    @Published var selectedEquipment: Set<Equipment> = [.barbell, .dumbbell]
    @Published var duration: Int = 45
    @Published var difficulty: Difficulty = .intermediate

    // MARK: - Generated workout state
    @Published var generatedWorkout: GeneratedWorkout?
    @Published var isGenerating = false
    @Published var errorMessage: String?

    // MARK: - Active workout state
    @Published var isWorkoutActive = false
    @Published var currentExerciseIndex = 0
    @Published var currentSetIndex = 0
    @Published var activeWorkout: GeneratedWorkout?
    @Published var workoutStartTime: Date?
    @Published var restTimeRemaining: Int = 0
    @Published var isResting = false

    private var restTask: Task<Void, Never>?
    private let llamaService = LlamaService.shared

    let durationOptions = [15, 20, 30, 45, 60, 75, 90]

    // MARK: - Generation

    func generateWorkout() async {
        errorMessage = nil
        isGenerating = true

        do {
            let workout = try await llamaService.generateWorkout(
                muscles: Array(selectedMuscles),
                equipment: Array(selectedEquipment),
                durationMinutes: duration,
                difficulty: difficulty
            )
            generatedWorkout = workout
        } catch {
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }

    // MARK: - Workout flow

    func startWorkout() {
        guard let workout = generatedWorkout else { return }
        activeWorkout = workout
        currentExerciseIndex = 0
        currentSetIndex = 0
        workoutStartTime = Date()
        isWorkoutActive = true
        isResting = false
    }

    var currentExercise: Exercise? {
        guard let workout = activeWorkout,
              currentExerciseIndex < workout.exercises.count else { return nil }
        return workout.exercises[currentExerciseIndex]
    }

    var totalSetsCompleted: Int {
        guard let workout = activeWorkout else { return 0 }
        var count = 0
        for i in 0..<currentExerciseIndex {
            count += workout.exercises[i].sets.count
        }
        count += currentSetIndex
        return count
    }

    var totalSets: Int {
        activeWorkout?.exercises.reduce(0) { $0 + $1.sets.count } ?? 0
    }

    var workoutElapsedSeconds: Int {
        guard let start = workoutStartTime else { return 0 }
        return Int(Date().timeIntervalSince(start))
    }

    func completeSet() {
        guard var workout = activeWorkout,
              currentExerciseIndex < workout.exercises.count else { return }

        let exercise = workout.exercises[currentExerciseIndex]

        if currentSetIndex < exercise.sets.count {
            workout.exercises[currentExerciseIndex].sets[currentSetIndex].isCompleted = true
            workout.exercises[currentExerciseIndex].sets[currentSetIndex].completedAt = Date()
            activeWorkout = workout
        }

        let nextSet = currentSetIndex + 1
        if nextSet < exercise.sets.count {
            currentSetIndex = nextSet
            startRestTimer(seconds: exercise.restSeconds)
        } else {
            let nextExercise = currentExerciseIndex + 1
            if nextExercise < workout.exercises.count {
                currentExerciseIndex = nextExercise
                currentSetIndex = 0
                startRestTimer(seconds: exercise.restSeconds)
            } else {
                finishWorkout()
            }
        }
    }

    func skipRest() {
        restTask?.cancel()
        restTask = nil
        isResting = false
        restTimeRemaining = 0
    }

    func finishWorkout() {
        restTask?.cancel()
        restTask = nil
        isWorkoutActive = false
        isResting = false
    }

    // MARK: - Rest timer

    private func startRestTimer(seconds: Int) {
        isResting = true
        restTimeRemaining = seconds

        restTask?.cancel()
        restTask = Task { @MainActor [weak self] in
            guard let self else { return }

            while self.restTimeRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                self.restTimeRemaining -= 1
            }

            self.isResting = false
            #if os(watchOS)
            WKInterfaceDevice.current().play(.notification)
            #endif
        }
    }
}
