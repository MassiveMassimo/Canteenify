import Foundation
import SwiftTokenizer

class CustomTokenizer {
    private let tokenizer: SwiftTokenizer.Tokenizer
    private var specialTokens: [String: Int] = [:]
    
    let endOfTextTokenId = 0
    let imStartTokenId = 1
    let imEndTokenId = 2
    
    init() {
        guard
            let vocabURL = Bundle.main.url(forResource: "vocab", withExtension: "json"),
            let mergesURL = Bundle.main.url(forResource: "merges", withExtension: "txt")
        else {
            fatalError("Failed to find vocab.json or merges.txt in bundle.")
        }
        
        let config = TokenizerConfig(vocab: vocabURL, merges: mergesURL)
        tokenizer = Tokenizer(config: config)
        
        // Load special tokens dynamically from vocab.json
        loadSpecialTokens(from: vocabURL)
    }
    
    // Load special tokens (e.g., <|endoftext|>, <|im_start|>)
    private func loadSpecialTokens(from vocabURL: URL) {
        guard let data = try? Data(contentsOf: vocabURL),
              let vocab = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] else {
            fatalError("Failed to load vocab.json")
        }
        
        // Define the special tokens you want to load dynamically
        let specialTokenNames = ["<|endoftext|>", "<|im_start|>", "<|im_end|>", "<repo_name>", "<reponame>"]
        
        for token in specialTokenNames {
            if let tokenId = vocab[token] {
                specialTokens[token] = tokenId
            }
        }
    }
    
    // Access the eosToken dynamically
    var eosToken: Int32 {
        return Int32(specialTokens["<|endoftext|>"] ?? 2) // Fallback to 2 if not found
    }
    
    /// Encodes text into token IDs (with BOS/EOS if needed)
    func encode(_ text: String, addBOS: Bool = false, addEOS: Bool = false) -> [Int32] {
        var tokens = tokenizer.encode(text: text)
        if addBOS {
            tokens = tokenizer.appendBOS(tokens: tokens)
        }
        if addEOS {
            tokens = tokenizer.appendEOS(tokens: tokens)
        }
        return tokens.map(Int32.init)
    }
    
    /// Decodes token IDs back into text
    func decode(_ ids: [Int32]) -> String {
        let tokens = ids.map(Int.init)
        return tokenizer.decode(tokens: tokenizer.stripBOS(tokens: tokenizer.stripEOS(tokens: tokens)))
    }
    
    func formatPrompt(_ text: String, systemPrompt: String? = nil) -> String {
        var formattedPrompt = ""
        
        // Add system prompt if provided
        if let sysPrompt = systemPrompt {
            formattedPrompt += "<|im_start|>system\n\(sysPrompt)<|im_end|>\n"
        }
        
        // Add user message
        formattedPrompt += "<|im_start|>user\n\(text)<|im_end|>\n"
        
        // Add assistant start
        formattedPrompt += "<|im_start|>assistant\n"
        
        return formattedPrompt
    }
}
