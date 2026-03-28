import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var photos: [GlassesPhoto] = []
    @Published var isCapturing = false

    private let connectivity = WatchConnectivityManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var modelContext: ModelContext?

    private var maxPhotos: Int {
        UserDefaults.standard.integer(forKey: "max_gallery_photos").clamped(to: 10...200, default: 50)
    }

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadPhotos()
        observeIncomingPhotos()
    }

    func loadPhotos() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<GlassesPhoto>(
            sortBy: [SortDescriptor(\.capturedAt, order: .reverse)]
        )
        photos = (try? context.fetch(descriptor)) ?? []
    }

    func requestCapture() {
        isCapturing = true
        connectivity.requestPhotoCapture()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.isCapturing = false
        }
    }

    func deletePhoto(_ photo: GlassesPhoto) {
        modelContext?.delete(photo)
        try? modelContext?.save()
        loadPhotos()
    }

    func generateCaption(for photo: GlassesPhoto) async -> String? {
        do {
            let caption = try await LlamaService.shared.captionImage(photo.imageData)
            photo.aiCaption = caption
            try? modelContext?.save()
            return caption
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private func observeIncomingPhotos() {
        connectivity.photoReceivedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] received in
                self?.persistPhoto(received)
            }
            .store(in: &cancellables)
    }

    private func persistPhoto(_ received: WatchConnectivityManager.ReceivedPhoto) {
        guard let context = modelContext else { return }

        let thumbnail = generateThumbnail(from: received.imageData) ?? received.imageData

        let photo = GlassesPhoto(
            imageData: received.imageData,
            thumbnailData: thumbnail,
            capturedAt: received.receivedAt
        )

        context.insert(photo)
        evictOldPhotos(context: context)
        try? context.save()
        loadPhotos()
        isCapturing = false
    }

    private func generateThumbnail(from data: Data, maxDimension: CGFloat = 80) -> Data? {
        #if os(watchOS)
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()

        return thumbnail?.jpegData(compressionQuality: 0.5)
        #else
        return nil
        #endif
    }

    private func evictOldPhotos(context: ModelContext) {
        let descriptor = FetchDescriptor<GlassesPhoto>(
            sortBy: [SortDescriptor(\.capturedAt, order: .reverse)]
        )
        guard let all = try? context.fetch(descriptor) else { return }

        if all.count > maxPhotos {
            for photo in all.dropFirst(maxPhotos) {
                context.delete(photo)
            }
        }
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>, default defaultValue: Int) -> Int {
        self == 0 ? defaultValue : Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
