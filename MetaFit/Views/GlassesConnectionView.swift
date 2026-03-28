import SwiftUI

struct GlassesConnectionView: View {
    @StateObject private var bridge = GlassesBridgeService.shared
    @StateObject private var connectivity = WatchConnectivityManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                statusHeader
                Spacer()
                connectionContent
                Spacer()
                watchStatus
            }
            .padding()
            .navigationTitle("MetaFit")
            .task { bridge.configure() }
        }
    }

    // MARK: - Status header

    private var statusHeader: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(statusText)
                .font(.subheadline.weight(.medium))
            Spacer()
        }
    }

    private var statusColor: Color {
        switch bridge.connectionState {
        case .disconnected: return .gray
        case .registering, .permissionPending: return .yellow
        case .registered: return .blue
        case .streaming: return .green
        case .error: return .red
        }
    }

    private var statusText: String {
        switch bridge.connectionState {
        case .disconnected: return "Not Connected"
        case .registering: return "Registering..."
        case .registered: return "Glasses Connected"
        case .permissionPending: return "Requesting Permission..."
        case .streaming: return "Streaming"
        case .error: return "Error"
        }
    }

    // MARK: - Main content

    @ViewBuilder
    private var connectionContent: some View {
        switch bridge.connectionState {
        case .disconnected:
            disconnectedView

        case .registering:
            ProgressView("Connecting to Meta AI...")

        case .registered:
            registeredView

        case .permissionPending:
            ProgressView("Requesting camera permission...")

        case .streaming:
            streamingView

        case .error:
            errorView
        }
    }

    private var disconnectedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "eyeglasses")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Connect Meta Glasses")
                .font(.title3.weight(.semibold))

            Text("Pair your Meta Ray-Ban glasses to capture gym photos and view them on your Apple Watch.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                bridge.startRegistration()
            } label: {
                Label("Connect Glasses", systemImage: "link")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
    }

    private var registeredView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Glasses Connected")
                .font(.title3.weight(.semibold))

            Text("Start streaming to capture photos from your glasses and send them to your Apple Watch.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await bridge.requestCameraAndStartStream() }
            } label: {
                Label("Start Camera", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    private var streamingView: some View {
        VStack(spacing: 12) {
            if let frame = bridge.latestFrame {
                Image(uiImage: frame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxHeight: 200)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay {
                        ProgressView("Waiting for frames...")
                    }
            }

            HStack {
                Label("\(bridge.photoCount) photos sent", systemImage: "photo.stack")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                Button {
                    bridge.capturePhoto()
                } label: {
                    Label("Capture", systemImage: "camera.shutter.button")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    bridge.stopStream()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)

            Text("Connection Error")
                .font(.title3.weight(.semibold))

            if let error = bridge.errorMessage {
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                bridge.startRegistration()
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Watch status

    private var watchStatus: some View {
        HStack {
            Image(systemName: "applewatch")
                .foregroundStyle(connectivity.isReachable ? .green : .gray)
            Text(connectivity.isReachable ? "Watch Connected" : "Watch Not Reachable")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }
}
