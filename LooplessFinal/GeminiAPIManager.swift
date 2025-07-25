import Foundation

struct GeminiAPIManager {
    static let apiKey = "AIzaSyABLHm-7qiyZBoMm6ThjrOc-orM3XhhjzE"

    static func analyzeVoiceJournalEntries(_ entries: [VoiceJournalEntry], completion: @escaping (String) -> Void) async {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-pro:generateContent?key=\(apiKey)")!

        // Convert entries to a readable format
        let formattedEntries = entries.map { entry in
            let dateStr = DateFormatter.localizedString(from: entry.date, dateStyle: .medium, timeStyle: .short)
            return "[\(dateStr)] \(entry.text)"
        }.joined(separator: "\n")

        let prompt = """
        You are a cognitive behavioral therapist analyzing a user's voice journal entries. Here are the entries:

        \(formattedEntries)

        Without acknowledging the prompt, immediately begin by identifying recurring emotional patterns, signs of distress or growth, and give clear, personalized behavioral suggestions or coping strategies. Be thorough, practical, and empathetic. Avoid listing or bullet points; use natural paragraph explanations and direct insights.
        """

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            if let decoded = try? JSONDecoder().decode(GeminiResponse.self, from: data),
               let text = decoded.candidates.first?.content.parts.first?.text {
                completion(text)
            } else {
                completion("⚠️ Gemini responded but no analysis was returned.")
            }
        } catch {
            completion("❌ Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - GeminiResponse

struct GeminiResponse: Codable {
    struct Candidate: Codable {
        struct Content: Codable {
            struct Part: Codable {
                let text: String
            }
            let parts: [Part]
        }
        let content: Content
    }
    let candidates: [Candidate]
}

