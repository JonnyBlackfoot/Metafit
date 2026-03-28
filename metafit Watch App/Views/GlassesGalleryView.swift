import SwiftUI
import SwiftData

struct GlassesGalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPhoto: GlassesPhoto?

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        Group {
            if viewModel.photos.isEmpty {
                emptyState
            } else {
                photoGrid
            }
        }
        .navigationTitle("Photos")
        .task { viewModel.setup(modelContext: modelContext) }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo, viewModel: viewModel)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "camera.fill")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("No Photos")
                .font(.caption.weight(.semibold))

            Text("Capture photos from your Meta glasses via the iPhone companion app.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            captureButton
        }
        .padding()
    }

    private var photoGrid: some View {
        ScrollView {
            VStack(spacing: 8) {
                captureButton

                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(viewModel.photos) { photo in
                        PhotoThumbnail(photo: photo) {
                            selectedPhoto = photo
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var captureButton: some View {
        Button {
            viewModel.requestCapture()
        } label: {
            HStack {
                if viewModel.isCapturing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "camera.shutter.button")
                }
                Text(viewModel.isCapturing ? "Capturing..." : "Capture")
                    .font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        .disabled(viewModel.isCapturing)
    }
}

struct PhotoThumbnail: View {
    let photo: GlassesPhoto
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            if let uiImage = UIImage(data: photo.thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 60)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}
