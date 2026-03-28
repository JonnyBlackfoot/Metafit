import Foundation
import WatchConnectivity
import Combine

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var isReachable = false
    @Published var lastReceivedPhoto: ReceivedPhoto?
    @Published var pendingCaptureRequest = false

    struct ReceivedPhoto {
        let imageData: Data
        let metadata: [String: Any]
        let receivedAt: Date
    }

    let photoReceivedSubject = PassthroughSubject<ReceivedPhoto, Never>()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Send photo from iPhone to Watch

    func sendPhotoToWatch(imageData: Data, metadata: [String: String] = [:]) {
        guard WCSession.default.activationState == .activated else { return }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")

        do {
            try imageData.write(to: tempURL)
            var meta: [String: Any] = metadata
            meta["type"] = "glasses_photo"
            meta["timestamp"] = ISO8601DateFormatter().string(from: Date())
            WCSession.default.transferFile(tempURL, metadata: meta)
        } catch {
            // File write failed; photo not sent
        }
    }

    // MARK: - Request photo capture from Watch (sends command to iPhone)

    func requestPhotoCapture() {
        guard WCSession.default.isReachable else { return }

        let message: [String: Any] = ["command": "capture_photo"]
        WCSession.default.sendMessage(message, replyHandler: nil) { _ in
            // Phone not reachable; user can retry
        }
    }

    // MARK: - Send message from either side

    func sendMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(message, replyHandler: replyHandler) { _ in }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    // Receive transferred files (photos from iPhone -> Watch)
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let metadata = file.metadata,
              metadata["type"] as? String == "glasses_photo" else { return }

        do {
            let data = try Data(contentsOf: file.fileURL)
            let photo = ReceivedPhoto(
                imageData: data,
                metadata: metadata,
                receivedAt: Date()
            )

            DispatchQueue.main.async {
                self.lastReceivedPhoto = photo
                self.photoReceivedSubject.send(photo)
            }
        } catch {
            // Failed to read transferred file
        }
    }

    // Receive messages (capture commands from Watch -> iPhone)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if message["command"] as? String == "capture_photo" {
            DispatchQueue.main.async {
                self.pendingCaptureRequest = true
            }
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        if message["command"] as? String == "capture_photo" {
            DispatchQueue.main.async {
                self.pendingCaptureRequest = true
            }
            replyHandler(["status": "capture_requested"])
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
