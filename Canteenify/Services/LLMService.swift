import Foundation
import CoreML

protocol LLMServiceProtocol {
    func generateResponse(from text: String) async -> String?
}

class LLMService: LLMServiceProtocol {
    private let model: MLModel
    private let tokenizer: CustomTokenizer // You’d use your own tokenizer class
    
    init() {
        // Load the Core ML model
        guard let url = Bundle.main.url(forResource: "SmolLM2-360M-Instruct-8bit", withExtension: "mlmodelc"),
              let loadedModel = try? MLModel(contentsOf: url) else {
            fatalError("Failed to load LLM model")
        }
        self.model = loadedModel
        
        // Initialize tokenizer (e.g. SwiftTokenizer backed)
        self.tokenizer = CustomTokenizer() // Assuming your tokenizer loads tokenizer.json
        
        for (name, desc) in model.modelDescription.inputDescriptionsByName {
            print("Input name: \(name)")
            if let multiArrayConstraint = desc.multiArrayConstraint {
                print("  Shape: \(multiArrayConstraint.shape)")
                print("  DataType: \(multiArrayConstraint.dataType.rawValue)")
            } else {
                print("  Not a MultiArray input.")
            }
        }
    }
    
    func generateResponse(from text: String) async -> String? {
        do {
            // Limit the prompt length to avoid excessive memory usage
            let maxPromptLength = 512  // Adjust based on your model's context window
            
            // Format the prompt and encode
            let formattedText = tokenizer.formatPrompt(text)
            var inputTokens = tokenizer.encode(formattedText, addBOS: false)
            
            // Trim too long prompts
            if inputTokens.count > maxPromptLength {
                inputTokens = Array(inputTokens.suffix(maxPromptLength))
            }
            
            // Preallocate array for generated tokens with a reasonable capacity
            var generatedTokens = [Int32]()
            generatedTokens.reserveCapacity(100)  // Reserve memory upfront
            
            // Limit maximum generation tokens
            let maxGenerationTokens = 100
            
            for _ in 0..<maxGenerationTokens {
                // Use last token for next prediction
                guard let lastToken = inputTokens.last else { break }
                
                // Create small, memory-efficient input arrays
                let inputArray = try MLMultiArray(shape: [1, 1], dataType: .int32)
                inputArray[0] = NSNumber(value: lastToken)
                
                let maskArray = try MLMultiArray(shape: [1, 1, 1, 1], dataType: .int32)
                maskArray[0] = 1
                
                // Create and release input features in a limited scope to help memory management
                let nextToken: Int32
                do {
                    let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [
                        "input_ids": inputArray,
                        "causal_mask": maskArray
                    ])
                    
                    let prediction = try await model.prediction(from: inputFeatures)
                    guard let logits = prediction.featureValue(for: "logits")?.multiArrayValue else {
                        break
                    }
                    
                    nextToken = decodeFromLogits(logits).first ?? 0
                }
                
                // Stop generation when we hit ending tokens
                if nextToken == tokenizer.eosToken ||
                    nextToken == Int32(tokenizer.imEndTokenId) {
                    break
                }
                
                generatedTokens.append(nextToken)
                inputTokens.append(nextToken)
                
                // Optional: Clean up memory if needed
                autoreleasepool {}
            }
            
            return tokenizer.decode(generatedTokens)
        } catch {
            print("LLM error: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func makeInputFeatures(inputIds: [Int32], causalMask: [Int32]) throws -> MLDictionaryFeatureProvider {
        let shape = [1, inputIds.count, 1, 1].map(NSNumber.init)
        
        let inputArray = try MLMultiArray(shape: shape, dataType: .int32)
        let maskArray = try MLMultiArray(shape: shape, dataType: .int32)
        
        for (i, id) in inputIds.enumerated() {
            inputArray[i] = NSNumber(value: id)
            maskArray[i] = NSNumber(value: causalMask[i])
        }
        
        return try MLDictionaryFeatureProvider(dictionary: [
            "input_ids": inputArray,
            "causal_mask": maskArray
        ])
    }
    
    private func decodeFromLogits(_ logits: MLMultiArray) -> [Int32] {
        // Naive decoding — take the argmax of last position
        // If logits shape is [1, seqLen, vocabSize], flatten and decode last token
        let logitsPointer = UnsafeMutablePointer<Float32>(OpaquePointer(logits.dataPointer))
        let vocabSize = logits.shape.last!.intValue
        let lastTokenStart = logits.count - vocabSize
        
        var maxIndex = 0
        var maxValue = logitsPointer[lastTokenStart]
        for i in 1..<vocabSize {
            let value = logitsPointer[lastTokenStart + i]
            if value > maxValue {
                maxValue = value
                maxIndex = i
            }
        }
        
        return [Int32(maxIndex)]
    }
}
