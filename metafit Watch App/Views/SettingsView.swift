import SwiftUI

struct SettingsView: View {
    @AppStorage("llama_api_key") private var apiKey = ""
    @AppStorage("llama_base_url") private var baseURL = "https://api.together.xyz/v1"
    @AppStorage("max_gallery_photos") private var maxPhotos = 50

    @StateObject private var connectivity = WatchConnectivityManager.shared
    @State private var showingAPIKeyInput = false

    var body: some View {
        List {
            aiSection
            gallerySection
            connectivitySection
            aboutSection
        }
        .navigationTitle("Settings")
    }

    // MARK: - AI configuration

    private var aiSection: some View {
        Section("AI Engine") {
            Button {
                showingAPIKeyInput = true
            } label: {
                HStack {
                    Label("API Key", systemImage: "key.fill")
                        .font(.caption)
                    Spacer()
                    Text(apiKey.isEmpty ? "Not Set" : "Configured")
                        .font(.caption2)
                        .foregroundStyle(apiKey.isEmpty ? .red : .green)
                }
            }
            .sheet(isPresented: $showingAPIKeyInput) {
                APIKeyInputView(apiKey: $apiKey)
            }

            VStack(alignment: .leading, spacing: 4) {
                Label("API Endpoint", systemImage: "server.rack")
                    .font(.caption)
                Text(baseURL)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            connectionStatusRow
        }
    }

    private var connectionStatusRow: some View {
        HStack {
            Label("Status", systemImage: "wifi")
                .font(.caption)
            Spacer()
            if apiKey.isEmpty {
                Text("No Key")
                    .font(.caption2)
                    .foregroundStyle(.red)
            } else {
                Text("Ready")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
        }
    }

    // MARK: - Gallery

    private var gallerySection: some View {
        Section("Photo Gallery") {
            Stepper(value: $maxPhotos, in: 10...200, step: 10) {
                HStack {
                    Label("Max Photos", systemImage: "photo.stack")
                        .font(.caption)
                    Spacer()
                    Text("\(maxPhotos)")
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                }
            }
        }
    }

    // MARK: - Connectivity

    private var connectivitySection: some View {
        Section("Connections") {
            HStack {
                Label("iPhone", systemImage: "iphone")
                    .font(.caption)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(connectivity.isReachable ? .green : .gray)
                        .frame(width: 6, height: 6)
                    Text(connectivity.isReachable ? "Connected" : "Not Reachable")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                    .font(.caption)
                Spacer()
                Text("1.0")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("AI Model", systemImage: "brain")
                    .font(.caption)
                Spacer()
                Text("Llama 3.2 8B")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - API Key input

struct APIKeyInputView: View {
    @Binding var apiKey: String
    @State private var inputText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text("Llama API Key")
                .font(.caption.weight(.semibold))

            Text("Enter your Together.ai or compatible API key.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("API Key", text: $inputText)
                .textContentType(.password)
                .font(.caption2)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    apiKey = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .onAppear {
            inputText = apiKey
        }
    }
}
