import Foundation
import UIKit
import Combine

#if canImport(MWDATCore) && canImport(MWDATCamera)
import MWDATCore
import MWDATCamera
#endif

enum GlassesConnectionState: String {
    case disconnected
    case registering
    case registered
    case permissionPending
    case streaming
    case error
}

@MainActor
final class GlassesBridgeService: ObservableObject {
    static let shared = GlassesBridgeService()

    @Published var connectionState: GlassesConnectionState = .disconnected
    @Published var errorMessage: String?
    @Published var latestFrame: UIImage?
    @Published var photoCount: Int = 0
    @Published var isStreamActive = false

    private let connectivity = WatchConnectivityManager.shared
    private var cancellables = Set<AnyCancellable>()

    #if canImport(MWDATCore) && canImport(MWDATCamera)
    private var streamSession: StreamSession?
    private var stateToken: Any?
    private var frameToken: Any?
    private var photoToken: Any?
    #endif

    private init() {
        setupCaptureRequestListener()
    }

    // MARK: - SDK initialization

    func configure() {
        #if canImport(MWDATCore)
        do {
            try Wearables.configure()
        } catch {
            connectionState = .error
            errorMessage = "Failed to configure Meta SDK: \(error.localizedDescription)"
        }
        #else
        errorMessage = "Meta Wearables SDK not available in this build."
        #endif
    }

    // MARK: - Registration

    func startRegistration() {
        #if canImport(MWDATCore)
        connectionState = .registering
        Task { @MainActor in
            do {
                try await Wearables.shared.startRegistration()
                observeRegistrationState()
            } catch {
                connectionState = .error
                errorMessage = "Registration failed: \(error.localizedDescription)"
            }
        }
        #endif
    }

    func handleCallback(url: URL) {
        #if canImport(MWDATCore)
        Task { @MainActor in
            do {
                _ = try await Wearables.shared.handleUrl(url)
            } catch {
                errorMessage = "Callback handling failed: \(error.localizedDescription)"
            }
        }
        #endif
    }

    // MARK: - Camera permission & streaming

    func requestCameraAndStartStream() async {
        #if canImport(MWDATCore) && canImport(MWDATCamera)
        connectionState = .permissionPending

        do {
            _ = try await Wearables.shared.requestPermission(.camera)
            await startCameraStream()
        } catch {
            connectionState = .error
            errorMessage = "Permission request failed: \(error.localizedDescription)"
        }
        #endif
    }

    func stopStream() {
        #if canImport(MWDATCamera)
        Task { @MainActor in
            await streamSession?.stop()
            streamSession = nil
            isStreamActive = false
            connectionState = .registered
        }
        #endif
    }

    // MARK: - Photo capture (triggered from Watch)

    func capturePhoto() {
        #if canImport(MWDATCamera)
        streamSession?.capturePhoto(format: .jpeg)
        #endif
    }

    // MARK: - Private

    private func observeRegistrationState() {
        #if canImport(MWDATCore)
        Task {
            for await state in Wearables.shared.registrationStateStream() {
                let stateText = String(describing: state).lowercased()
                if stateText.contains("registered") {
                    connectionState = .registered
                } else if stateText.contains("unregistered") || stateText.contains("notregistered") {
                    connectionState = .disconnected
                }
            }
        }

        Task {
            for await devices in Wearables.shared.devicesStream() {
                if !devices.isEmpty && connectionState == .registered {
                    // Device connected; ready for streaming
                }
            }
        }
        #endif
    }

    private func startCameraStream() async {
        #if canImport(MWDATCore) && canImport(MWDATCamera)
        let deviceSelector = AutoDeviceSelector(wearables: Wearables.shared)
        let config = StreamSessionConfig(
            videoCodec: .raw,
            resolution: .low,
            frameRate: 7
        )

        let session = StreamSession(streamSessionConfig: config, deviceSelector: deviceSelector)
        self.streamSession = session

        stateToken = session.statePublisher.listen { [weak self] state in
            Task { @MainActor [weak self] in
                switch state {
                case .streaming:
                    self?.connectionState = .streaming
                    self?.isStreamActive = true
                case .stopped:
                    self?.isStreamActive = false
                default:
                    break
                }
            }
        }

        frameToken = session.videoFramePublisher.listen { [weak self] frame in
            guard let image = frame.makeUIImage() else { return }
            Task { @MainActor [weak self] in
                self?.latestFrame = image
            }
        }

        photoToken = session.photoDataPublisher.listen { [weak self] photoData in
            Task { @MainActor [weak self] in
                self?.handleCapturedPhoto(photoData.data)
            }
        }

        await session.start()
        connectionState = .streaming
        #endif
    }

    private func handleCapturedPhoto(_ data: Data) {
        let compressed = compressJPEG(data, targetBytes: 100_000)

        photoCount += 1
        connectivity.sendPhotoToWatch(
            imageData: compressed,
            metadata: ["index": "\(photoCount)"]
        )
    }

    private func compressJPEG(_ data: Data, targetBytes: Int) -> Data {
        guard let image = UIImage(data: data) else { return data }

        var quality: CGFloat = 0.8
        var compressed = image.jpegData(compressionQuality: quality) ?? data

        while compressed.count > targetBytes, quality > 0.1 {
            quality -= 0.1
            compressed = image.jpegData(compressionQuality: quality) ?? compressed
        }

        return compressed
    }

    private func setupCaptureRequestListener() {
        connectivity.$pendingCaptureRequest
            .filter { $0 }
            .sink { [weak self] _ in
                self?.capturePhoto()
                self?.connectivity.pendingCaptureRequest = false
            }
            .store(in: &cancellables)
    }
}
