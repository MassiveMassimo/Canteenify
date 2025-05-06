import SwiftUI
import Vision

// MARK: - Protocol
protocol ImageProcessingService {
    func extractText(from imageData: Data) async throws -> String
}

// MARK: - Implementation
class VisionImageProcessingService: ImageProcessingService {
    enum ImageProcessingError: Error {
        case invalidImage
        case processingFailed
        case noTextFound
    }
    
    func extractText(from imageData: Data) async throws -> String {
        guard let cgImage = UIImage(data: imageData)?.cgImage else {
            throw ImageProcessingError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ImageProcessingError.processingFailed)
                    return
                }
                
                let extractedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                if extractedText.isEmpty {
                    continuation.resume(throwing: ImageProcessingError.noTextFound)
                } else {
                    continuation.resume(returning: extractedText)
                }
            }
            
            // Configure the text recognition request
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
