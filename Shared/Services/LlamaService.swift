import Foundation
import Combine

enum LlamaServiceError: LocalizedError {
    case noAPIKey
    case offline
    case invalidResponse
    case httpError(Int)
    case decodingFailed(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .noAPIKey: return "No API key configured. Add your Llama API key in Settings."
        case .offline: return "No network connection. Connect to WiFi or cellular to generate workouts."
        case .invalidResponse: return "Received an invalid response from the AI service."
        case .httpError(let code): return "Server error (HTTP \(code)). Please try again."
        case .decodingFailed(let detail): return "Failed to parse workout: \(detail)"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        }
    }
}

@MainActor
final class LlamaService: ObservableObject {
    static let shared = LlamaService()

    @Published var isGenerating = false

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.allowsCellularAccess = true
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        return URLSession(configuration: config)
    }()

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "llama_api_key") ?? ""
    }

    private var baseURL: String {
        UserDefaults.standard.string(forKey: "llama_base_url")
            ?? "https://api.together.xyz/v1"
    }

    // MARK: - Workout generation

    func generateWorkout(
        muscles: [MuscleGroup],
        equipment: [Equipment],
        durationMinutes: Int,
        difficulty: Difficulty
    ) async throws -> GeneratedWorkout {
        guard !apiKey.isEmpty else { throw LlamaServiceError.noAPIKey }

        isGenerating = true
        defer { isGenerating = false }

        let prompt = buildWorkoutPrompt(
            muscles: muscles,
            equipment: equipment,
            durationMinutes: durationMinutes,
            difficulty: difficulty
        )

        let responseText = try await callLlamaAPI(
            systemPrompt: workoutSystemPrompt,
            userPrompt: prompt,
            model: "meta-llama/Llama-3.2-8B-Instruct-Turbo"
        )

        return try parseWorkoutResponse(responseText, muscles: muscles, difficulty: difficulty)
    }

    // MARK: - Image captioning (multimodal)

    func captionImage(_ imageData: Data) async throws -> String {
        guard !apiKey.isEmpty else { throw LlamaServiceError.noAPIKey }

        let base64 = imageData.base64EncodedString()
        let responseText = try await callLlamaAPI(
            systemPrompt: "You are a concise image captioner. Describe what you see in 1-2 sentences, focusing on gym or fitness context if applicable.",
            userPrompt: "Describe this image briefly.",
            model: "meta-llama/Llama-4-Scout-17B-16E-Instruct",
            imageBase64: base64
        )

        return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - API call

    private func callLlamaAPI(
        systemPrompt: String,
        userPrompt: String,
        model: String,
        imageBase64: String? = nil
    ) async throws -> String {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var userContent: Any
        if let imageBase64 {
            userContent = [
                ["type": "text", "text": userPrompt],
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(imageBase64)"]]
            ]
        } else {
            userContent = userPrompt
        }

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userContent]
            ],
            "temperature": 0.7,
            "max_tokens": 2048
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .notConnectedToInternet
            || error.code == .networkConnectionLost {
            throw LlamaServiceError.offline
        } catch {
            throw LlamaServiceError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LlamaServiceError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw LlamaServiceError.httpError(httpResponse.statusCode)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw LlamaServiceError.invalidResponse
        }

        return content
    }

    // MARK: - Prompt engineering

    private var workoutSystemPrompt: String {
        """
        You are an expert strength and conditioning coach. Generate structured gym workouts.

        RULES:
        - Follow exercise science: compound movements before isolation, appropriate rest periods.
        - Beginner: 2-3 sets, 10-15 reps, longer rest (90s). Intermediate: 3-4 sets, 8-12 reps, 60-90s rest. Advanced: 4-5 sets, 6-10 reps, 45-60s rest with supersets.
        - Match exercises to the available equipment only.
        - Include warm-up sets at lower weight where appropriate.
        - Total workout time should match the requested duration.

        OUTPUT FORMAT: Respond with ONLY valid JSON matching this schema (no markdown, no explanation):
        {
          "name": "string",
          "exercises": [
            {
              "name": "string",
              "muscleGroup": "chest|back|shoulders|biceps|triceps|forearms|quads|hamstrings|glutes|calves|abs|obliques|full_body",
              "equipment": "barbell|dumbbell|kettlebell|cable|machine|bodyweight|resistance_band|pull_up_bar",
              "sets": [{"reps": int, "weight": null}],
              "restSeconds": int,
              "notes": "string or null"
            }
          ],
          "estimatedMinutes": int
        }
        """
    }

    private func buildWorkoutPrompt(
        muscles: [MuscleGroup],
        equipment: [Equipment],
        durationMinutes: Int,
        difficulty: Difficulty
    ) -> String {
        let muscleNames = muscles.map(\.displayName).joined(separator: ", ")
        let equipmentNames = equipment.map(\.displayName).joined(separator: ", ")

        return """
        Generate a \(difficulty.displayName.lowercased()) gym workout targeting: \(muscleNames).
        Available equipment: \(equipmentNames).
        Target duration: \(durationMinutes) minutes.
        """
    }

    // MARK: - Response parsing

    private func parseWorkoutResponse(
        _ text: String,
        muscles: [MuscleGroup],
        difficulty: Difficulty
    ) throws -> GeneratedWorkout {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw LlamaServiceError.decodingFailed("Response is not valid UTF-8")
        }

        struct APIWorkout: Decodable {
            let name: String
            let exercises: [Exercise]
            let estimatedMinutes: Int
        }

        do {
            let decoded = try JSONDecoder().decode(APIWorkout.self, from: data)
            return GeneratedWorkout(
                name: decoded.name,
                exercises: decoded.exercises,
                estimatedMinutes: decoded.estimatedMinutes,
                difficulty: difficulty,
                targetMuscles: muscles
            )
        } catch {
            throw LlamaServiceError.decodingFailed(error.localizedDescription)
        }
    }
}
