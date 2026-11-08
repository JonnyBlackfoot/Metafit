import SwiftUI

struct ExercisePickerView: View {
    let onSelect: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory?

    var body: some View {
        NavigationStack {
            List {
                if selectedCategory == nil {
                    categoryList
                } else {
                    exerciseList
                }
            }
            .navigationTitle(selectedCategory?.rawValue ?? "Exercises")
            .toolbar {
                if selectedCategory != nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back") {
                            selectedCategory = nil
                        }
                    }
                }
            }
        }
    }

    private var categoryList: some View {
        ForEach(ExerciseCategory.allCases) { category in
            Button {
                selectedCategory = category
            } label: {
                HStack {
                    Image(systemName: category.systemImage)
                        .frame(width: 24)
                        .foregroundStyle(.green)
                    Text(category.rawValue)
                    Spacer()
                    Text("\(ExerciseLibrary.exercises(for: category).count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var exerciseList: some View {
        ForEach(filteredExercises) { exercise in
            Button {
                onSelect(exercise)
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.caption)
                    if exercise.isBodyweight {
                        Text("Bodyweight")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var filteredExercises: [Exercise] {
        guard let category = selectedCategory else { return [] }
        return ExerciseLibrary.exercises(for: category)
    }
}
