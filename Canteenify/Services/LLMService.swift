import Foundation
import SwiftTokenizer
import CoreML

class LLMService {
    private let tokenizer: Tokenizer
    private let model: MLModel
    
    init?() {
        // Load tokenizer
        guard let vocabURL = Bundle.main.url(forResource: "vocab", withExtension: "json"),
              let mergesURL = Bundle.main.url(forResource: "merges", withExtension: "txt") else {
            print("Tokenizer files not found.")
            return nil
        }
        
        self.tokenizer = Tokenizer(config: TokenizerConfig(vocab: vocabURL, merges: mergesURL))
        
        // Load model
        guard let modelURL = Bundle.main.url(forResource: "SmolLM2-360M-Instruct-8bit", withExtension: "mlmodelc"),
              let model = try? MLModel(contentsOf: modelURL) else {
            print("Failed to load model.")
            return nil
        }
        
        self.model = model
    }
    
    func predict(text: String) -> String {
        let inputTokens = tokenizer.encode(text: text)
        
        // Prepare input_ids array - model expects shape [1, 1]
        guard let mlInput = try? MLMultiArray(shape: [1, 1], dataType: .int32) else {
            return "Failed to create input array"
        }
        
        // Only use the first token for now (or last token if you prefer)
        if inputTokens.count > 0 {
            mlInput[0] = NSNumber(value: inputTokens[0])
        }
        
        // Prepare causal_mask array with shape [1, 1, 1, 1]
        guard let maskArray = try? MLMultiArray(shape: [1, 1, 1, 1], dataType: .float16) else {
            return "Failed to create causal_mask"
        }
        
        // Fill with 1.0 (using float16)
        maskArray[0] = 1.0
        
        let input = LLMInput(input_ids: mlInput, causal_mask: maskArray)
        
        do {
            let prediction = try model.prediction(from: input)
            if let logits = prediction.featureValue(for: "logits")?.multiArrayValue {
                print("Logits shape: \(logits.shape)")
                
                // Since we don't know the exact shape, let's first print some info
                let logitsCount = logits.count
                print("Logits count: \(logitsCount)")
                
                // Attempt to find the largest logit (assuming it's a flat array of vocab_size)
                var maxIndex = 0
                var maxValue: Float = -Float.greatestFiniteMagnitude
                
                for i in 0..<logitsCount {
                    if let value = try? logits[i].floatValue, value > maxValue {
                        maxValue = value
                        maxIndex = i
                    }
                }
                
                let nextToken = maxIndex
                let outputTokens = inputTokens + [nextToken]
                return tokenizer.decode(tokens: outputTokens)
            }
        } catch {
            print("Prediction failed: \(error)")
        }
        
        return "Failed to predict"
    }
    
    private func argmax(array: [NSNumber]) -> Int {
        var maxIndex = 0
        var maxValue = array[0].doubleValue
        for i in 0..<array.count {
            let value = array[i].doubleValue
            if value > maxValue {
                maxValue = value
                maxIndex = i
            }
        }
        return maxIndex
    }
}


class LLMInput: MLFeatureProvider {
    let input_ids: MLMultiArray
    let causal_mask: MLMultiArray
    
    init(input_ids: MLMultiArray, causal_mask: MLMultiArray) {
        self.input_ids = input_ids
        self.causal_mask = causal_mask
    }
    
    var featureNames: Set<String> {
        return ["input_ids", "causal_mask"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "input_ids":
            return MLFeatureValue(multiArray: input_ids)
        case "causal_mask":
            return MLFeatureValue(multiArray: causal_mask)
        default:
            return nil
        }
    }
}
