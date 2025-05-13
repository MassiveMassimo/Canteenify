import SwiftUI
import SwiftData

extension HomePage {
    @Observable
    class HomeViewModel {
        // MARK: - Dependencies
        private let imageProcessingService: ImageProcessingService
        private let llmService: LLMServiceProtocol
        
        // MARK: - State
        var receiptImageData: Data?
        var extractedText: String?
        var isProcessing: Bool = false
        var processingError: Error?
        
        // Add LLM response state
        var llmResponse: String?
        var isProcessingLLM: Bool = false
        var llmError: Error?
        
        // MARK: - OrderItem fields
        var orderNumber: String = ""
        var orderDateTime: Date = Date()
        var price: Double = 0.0
        var dishes: [String] = []
        var restaurantName: String = ""
        var paymentMethod: String = ""
        
        // MARK: - Initialization
        init(
            imageProcessingService: ImageProcessingService = VisionImageProcessingService(),
            llmService: LLMServiceProtocol = LLMService()
        ) {
            self.imageProcessingService = imageProcessingService
            self.llmService = llmService
        }
        
        // MARK: - Actions
        func handleReceiptImageSelected(_ imageData: Data) {
            receiptImageData = imageData
            extractedText = nil
            llmResponse = nil
            processingError = nil
            llmError = nil
            
            Task {
                await processReceiptImage()
            }
        }
        
        @MainActor
        private func processReceiptImage() async {
            guard let imageData = receiptImageData else { return }
            
            isProcessing = true
            
            do {
                let text = try await imageProcessingService.extractText(from: imageData)
                extractedText = text
                print("Extracted Text (\(text.count) characters):")
                print(text)
                
                // Generate LLM response
                isProcessingLLM = true
                
                let prompt = """
                Extract the following information from this receipt:
                - Order Number
                - Date and Time
                - Total Price
                - Restaurant Name
                - Items Ordered
                - Payment Method
                
                Here is the receipt text:
                \(text)
                
                Answer:
                """
                
                llmResponse = await llmService.generateResponse(from: prompt)
                isProcessingLLM = false
                
                if let response = llmResponse {
                    print("LLM Response:")
                    print(response)
                } else {
                    print("No LLM response generated")
                }
                
            } catch {
                processingError = error
                print("Error processing receipt: \(error.localizedDescription)")
            }
            
            isProcessing = false
        }
        
        func createOrderItem(modelContext: ModelContext) -> OrderItem? {
            guard !orderNumber.isEmpty, price > 0 else { return nil }
            
            let order = OrderItem(
                orderNumber: orderNumber,
                dateTime: orderDateTime,
                price: price,
                receiptImage: receiptImageData,
                proofImage: nil,
                dishes: dishes,
                verificationStatus: .pending,
                restaurantName: restaurantName,
                paymentMethod: paymentMethod
            )
            
            modelContext.insert(order)
            try? modelContext.save()
            
            return order
        }
    }
}
