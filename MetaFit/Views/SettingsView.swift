import SwiftUI

struct PhoneSettingsView: View {
    @StateObject private var bridge = GlassesBridgeService.shared
    @StateObject private var connectivity = WatchConnectivityManager.shared

    var body: some View {
        List {
            glassesSection
            watchSection
        }
        .navigationTitle("Settings")
    }

    private var glassesSection: some View {
        Section("Meta Glasses") {
            HStack {
                Label("Connection", systemImage: "eyeglasses")
                Spacer()
                Text(bridge.connectionState.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Photos Sent", systemImage: "photo.stack")
                Spacer()
                Text("\(bridge.photoCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if bridge.connectionState == .streaming {
                Button("Stop Stream") {
                    bridge.stopStream()
                }
                .foregroundStyle(.red)
            }
        }
    }

    private var watchSection: some View {
        Section("Apple Watch") {
            HStack {
                Label("Status", systemImage: "applewatch")
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(connectivity.isReachable ? .green : .gray)
                        .frame(width: 8, height: 8)
                    Text(connectivity.isReachable ? "Connected" : "Not Reachable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
