import SwiftUI

struct PhotoDetailView: View {
    let photo: GlassesPhoto
    @ObservedObject var viewModel: GalleryViewModel

    @State private var zoomScale: CGFloat = 1.0
    @State private var caption: String?
    @State private var isLoadingCaption = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                photoImage
                metadataSection
                captionSection
                deleteButton
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Photo")
        .onAppear {
            caption = photo.aiCaption
        }
    }

    // MARK: - Photo with Digital Crown zoom

    private var photoImage: some View {
        Group {
            if let uiImage = UIImage(data: photo.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(zoomScale)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .focusable()
                    #if os(watchOS)
                    .digitalCrownRotation(
                        $zoomScale,
                        from: 1.0,
                        through: 4.0,
                        by: 0.1,
                        sensitivity: .medium
                    )
                    #endif
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
            }
        }
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                Text(photo.capturedAt, style: .date)
                Text(photo.capturedAt, style: .time)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Text(formatBytes(photo.sizeBytes))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - AI caption

    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let caption, !caption.isEmpty {
                Label("AI Caption", systemImage: "sparkles")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.purple)
                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    Task { await loadCaption() }
                } label: {
                    HStack {
                        if isLoadingCaption {
                            ProgressView()
                                .tint(.purple)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isLoadingCaption ? "Analyzing..." : "AI Caption")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.purple)
                .disabled(isLoadingCaption)
            }
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive) {
            viewModel.deletePhoto(photo)
            dismiss()
        } label: {
            Label("Delete", systemImage: "trash")
                .font(.caption2)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.red)
    }

    // MARK: - Helpers

    private func loadCaption() async {
        isLoadingCaption = true
        caption = await viewModel.generateCaption(for: photo)
        isLoadingCaption = false
    }

    private func formatBytes(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        }
        return String(format: "%.1f MB", kb / 1024)
    }
}
