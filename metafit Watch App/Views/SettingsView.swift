import SwiftUI

struct SettingsView: View {
    @AppStorage("llama_api_key") private var apiKey = ""
    @AppStorage("llama_base_url") private var baseURL = "https://api.openai.com/v1"
    @AppStorage("max_gallery_photos") private var maxPhotos = 50

    @StateObject private var connectivity = WatchConnectivityManager.shared
    @State private var showingAPIKeyInput = false
    @State private var showingEndpointInput = false
    private let isSimulator: Bool = {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }()

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

            Button {
                showingEndpointInput = true
            } label: {
                HStack {
                    Label("API Endpoint", systemImage: "server.rack")
                        .font(.caption)
                    Spacer()
                    Text(shortEndpointLabel(baseURL))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $showingEndpointInput) {
                EndpointInputView(baseURL: $baseURL)
            }

            connectionStatusRow
        }
    }

    private var connectionStatusRow: some View {
        HStack {
            Label("Status", systemImage: "wifi")
                .font(.caption)
            Spacer()
            if apiKey.isEmpty && isSimulator {
                Text("Simulator Demo")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
            } else if apiKey.isEmpty {
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
                Text(baseURL.contains("openai.com") ? "GPT-4o mini" : "Llama 3.2 8B")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func shortEndpointLabel(_ endpoint: String) -> String {
        if endpoint.contains("openai.com") { return "OpenAI" }
        if endpoint.contains("together.xyz") { return "Together" }
        return "Custom"
    }
}

// MARK: - API Key input

struct APIKeyInputView: View {
    @Binding var apiKey: String
    @State private var inputText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text("AI API Key")
                .font(.caption.weight(.semibold))

            Text("Enter your OpenAI, Together, or compatible API key.")
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

struct EndpointInputView: View {
    @Binding var baseURL: String
    @State private var inputText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text("API Endpoint")
                .font(.caption.weight(.semibold))

            Text("Use OpenAI by default, or switch to Together/custom.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("https://api.openai.com/v1", text: $inputText)
                .font(.caption2)

            HStack {
                Button("OpenAI") {
                    inputText = "https://api.openai.com/v1"
                }
                .buttonStyle(.bordered)

                Button("Together") {
                    inputText = "https://api.together.xyz/v1"
                }
                .buttonStyle(.bordered)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    baseURL = trimmed.isEmpty ? "https://api.openai.com/v1" : trimmed
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .onAppear {
            inputText = baseURL
        }
    }
}
