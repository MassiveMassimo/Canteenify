import Foundation

// MARK: - Gemini API Models

struct GeminiRequest: Encodable {
    let contents: [ContentItem]
    let generationConfig: GenerationConfig?
    
    struct ContentItem: Encodable {
        let parts: [Part]
    }
    
    struct Part: Encodable {
        let text: String
    }
    
    struct GenerationConfig: Encodable {
        let temperature: Float?
        let topK: Int?
        let topP: Float?
        let maxOutputTokens: Int?
        
        // CodingKeys with snake_case for API compatibility
        enum CodingKeys: String, CodingKey {
            case temperature
            case topK = "top_k"
            case topP = "top_p"
            case maxOutputTokens = "max_output_tokens"
        }
    }
    
    // CodingKeys with snake_case for API compatibility
    enum CodingKeys: String, CodingKey {
        case contents
        case generationConfig = "generation_config"
    }
}

struct GeminiResponse: Decodable {
    let candidates: [Candidate]?
    let promptFeedback: PromptFeedback?
    let error: GeminiError?
    
    struct Candidate: Decodable {
        let content: Content
        let finishReason: String?
        let index: Int?
        
        enum CodingKeys: String, CodingKey {
            case content
            case finishReason = "finish_reason"
            case index
        }
    }
    
    struct Content: Decodable {
        let parts: [Part]
        let role: String?
    }
    
    struct Part: Decodable {
        let text: String?
    }
    
    struct PromptFeedback: Decodable {
        let safetyRatings: [SafetyRating]?
        
        enum CodingKeys: String, CodingKey {
            case safetyRatings = "safety_ratings"
        }
    }
    
    struct SafetyRating: Decodable {
        let category: String
        let probability: String
    }
    
    enum CodingKeys: String, CodingKey {
        case candidates
        case promptFeedback = "prompt_feedback"
        case error
    }
}

struct GeminiError: Decodable {
    let code: Int
    let message: String
    let status: String
}

// MARK: - Simple Gemini LLM Service Implementation

class GeminiLLMService: LLMServiceProtocol {
    // MARK: - Properties
    private let apiKey: String
    private let modelName: String
    
    // MARK: - Initialization
    init(apiKey: String, modelName: String = "gemini-2.5-flash-preview-04-17") {
        self.apiKey = apiKey
        self.modelName = modelName
    }
    
    // MARK: - LLMServiceProtocol Implementation
    func generateResponse(from promptText: String) async -> String? {
        // Create URL for the API request
        let baseURL = "https://generativelanguage.googleapis.com/v1beta"
        let endpoint = "\(baseURL)/models/\(modelName):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return nil
        }
        
        // Create the request
        let request = GeminiRequest(
            contents: [
                GeminiRequest.ContentItem(
                    parts: [GeminiRequest.Part(text: promptText)]
                )
            ],
            generationConfig: GeminiRequest.GenerationConfig(
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 2048
            )
        )
        
        do {
            // Encode the request body
            let jsonEncoder = JSONEncoder()
            let requestData = try jsonEncoder.encode(request)
            
            // Create the HTTP request
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = requestData
            
            // Perform the request
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Check for successful response
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode >= 200, httpResponse.statusCode < 300 else {
                print("HTTP error: \(String(describing: response))")
                
                // Try to decode error response
                if let errorResponse = try? JSONDecoder().decode(GeminiResponse.self, from: data),
                   let error = errorResponse.error {
                    print("API error: \(error.code) - \(error.message)")
                }
                return nil
            }
            
            // Decode the response
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            // Extract the text from the response
            if let candidate = geminiResponse.candidates?.first,
               let part = candidate.content.parts.first,
               let text = part.text {
                return text
            } else {
                print("No text in response")
                return nil
            }
            
        } catch {
            print("Error generating response: \(error)")
            return nil
        }
    }
}

// MARK: - Helper Extension
extension GeminiLLMService {
    // Convenience method to create with API key from environment
    static func createWithDefaultAPIKey() -> GeminiLLMService? {
        // Read API key from Info.plist
        guard let infoDictionary = Bundle.main.infoDictionary,
              let apiKey = infoDictionary["GeminiAPIKey"] as? String else {
            print("Error: Gemini API key not found in Info.plist")
            return nil
        }
        
        return GeminiLLMService(apiKey: apiKey)
    }
}
