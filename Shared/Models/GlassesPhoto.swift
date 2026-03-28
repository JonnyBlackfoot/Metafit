import Foundation
import SwiftData

@Model
final class GlassesPhoto {
    var id: UUID
    var capturedAt: Date
    var imageData: Data
    var thumbnailData: Data
    var aiCaption: String?
    var sizeBytes: Int

    init(
        imageData: Data,
        thumbnailData: Data,
        capturedAt: Date = Date(),
        aiCaption: String? = nil
    ) {
        self.id = UUID()
        self.capturedAt = capturedAt
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.aiCaption = aiCaption
        self.sizeBytes = imageData.count
    }
}
