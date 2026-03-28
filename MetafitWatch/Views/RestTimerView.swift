import SwiftUI

struct RestTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timeRemaining: Int = 90
    @State private var totalTime: Int = 90
    @State private var isRunning = false
    @State private var timer: Timer?

    private let presets = [30, 60, 90, 120, 180]

    var body: some View {
        VStack(spacing: 12) {
            Text("Rest Timer")
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                VStack(spacing: 2) {
                    Text(formattedTime)
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.bold)
                    Text("remaining")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)

            if !isRunning {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(presets, id: \.self) { seconds in
                            Button {
                                timeRemaining = seconds
                                totalTime = seconds
                            } label: {
                                Text(formatPreset(seconds))
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.bordered)
                            .tint(totalTime == seconds ? .blue : .gray)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                if isRunning {
                    Button("Stop") {
                        stopTimer()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                } else {
                    Button("Start") {
                        startTimer()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }

                Button("Done") {
                    stopTimer()
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .font(.caption)
        }
        .padding()
        .onDisappear {
            stopTimer()
        }
    }

    private var progress: CGFloat {
        guard totalTime > 0 else { return 0 }
        return CGFloat(timeRemaining) / CGFloat(totalTime)
    }

    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func formatPreset(_ seconds: Int) -> String {
        if seconds >= 60 {
            let min = seconds / 60
            let sec = seconds % 60
            return sec > 0 ? "\(min)m\(sec)s" : "\(min)m"
        }
        return "\(seconds)s"
    }

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
}
