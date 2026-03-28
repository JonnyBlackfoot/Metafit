import SwiftUI

struct WorkoutGeneratorView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showGenerated = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                muscleGroupSection
                equipmentSection
                durationSection
                difficultySection
                generateButton
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("AI Workout")
        .sheet(isPresented: $showGenerated) {
            if let workout = viewModel.generatedWorkout {
                GeneratedWorkoutDetailView(
                    workout: workout,
                    viewModel: viewModel
                )
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Sections

    private var muscleGroupSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Muscles", systemImage: "figure.strengthtraining.traditional")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 4) {
                ForEach(MuscleGroup.allCases) { muscle in
                    ChipButton(
                        title: muscle.displayName,
                        isSelected: viewModel.selectedMuscles.contains(muscle)
                    ) {
                        toggleMuscle(muscle)
                    }
                }
            }
        }
    }

    private var equipmentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Equipment", systemImage: "dumbbell.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 4) {
                ForEach(Equipment.allCases) { equip in
                    ChipButton(
                        title: equip.displayName,
                        isSelected: viewModel.selectedEquipment.contains(equip)
                    ) {
                        toggleEquipment(equip)
                    }
                }
            }
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Duration", systemImage: "clock.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Picker("Duration", selection: $viewModel.duration) {
                ForEach(viewModel.durationOptions, id: \.self) { mins in
                    Text("\(mins) min").tag(mins)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 50)
        }
    }

    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Difficulty", systemImage: "flame.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Picker("Difficulty", selection: $viewModel.difficulty) {
                ForEach(Difficulty.allCases) { d in
                    Text(d.displayName).tag(d)
                }
            }
            .pickerStyle(.automatic)
        }
    }

    private var generateButton: some View {
        Button {
            Task { await viewModel.generateWorkout() }
            showGenerated = true
        } label: {
            HStack {
                if viewModel.isGenerating {
                    ProgressView()
                        .tint(.black)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(viewModel.isGenerating ? "Generating..." : "Generate Workout")
            }
            .frame(maxWidth: .infinity)
            .font(.body.weight(.semibold))
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .disabled(viewModel.isGenerating || viewModel.selectedMuscles.isEmpty)
        .padding(.top, 4)
    }

    // MARK: - Helpers

    private func toggleMuscle(_ muscle: MuscleGroup) {
        if viewModel.selectedMuscles.contains(muscle) {
            viewModel.selectedMuscles.remove(muscle)
        } else {
            viewModel.selectedMuscles.insert(muscle)
        }
    }

    private func toggleEquipment(_ equip: Equipment) {
        if viewModel.selectedEquipment.contains(equip) {
            viewModel.selectedEquipment.remove(equip)
        } else {
            viewModel.selectedEquipment.insert(equip)
        }
    }
}

// MARK: - Generated workout detail

struct GeneratedWorkoutDetailView: View {
    let workout: GeneratedWorkout
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(workout.name)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label("\(workout.estimatedMinutes)m", systemImage: "clock")
                    Label("\(workout.exercises.count)", systemImage: "list.number")
                    Label(workout.difficulty.displayName, systemImage: "flame")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Divider()

                ForEach(workout.exercises) { exercise in
                    ExerciseRow(exercise: exercise)
                }

                Button {
                    viewModel.startWorkout()
                    dismiss()
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Your Plan")
    }
}

struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 8) {
                Text("\(exercise.sets.count) sets")
                if let reps = exercise.sets.first?.reps {
                    Text("x \(reps) reps")
                }
                Text("\(exercise.restSeconds)s rest")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Chip button

struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                .foregroundStyle(isSelected ? .green : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow layout for chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            guard index < result.positions.count else { break }
            subview.place(at: CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            ), proposal: .unspecified)
        }
    }

    private struct LayoutResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return LayoutResult(
            positions: positions,
            size: CGSize(width: maxWidth, height: totalHeight)
        )
    }
}
