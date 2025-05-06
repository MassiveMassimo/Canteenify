import SwiftUI
import SwiftData

extension HomePage {
    @Observable
    class HomeViewModel {
        // MARK: - Dependencies
        private let imageProcessingService: ImageProcessingService
        
        // MARK: - State
        var receiptImageData: Data?
        var extractedText: String?
        var isProcessing: Bool = false
        var processingError: Error?
        
        // MARK: - OrderItem fields
        var orderNumber: String = ""
        var orderDateTime: Date = Date()
        var price: Double = 0.0
        var dishes: [String] = []
        var restaurantName: String = ""
        var paymentMethod: String = ""
        
        // MARK: - Initialization
        init(imageProcessingService: ImageProcessingService = VisionImageProcessingService()) {
            self.imageProcessingService = imageProcessingService
        }
        
        // MARK: - Actions
        func handleReceiptImageSelected(_ imageData: Data) {
            receiptImageData = imageData
            extractedText = nil
            processingError = nil
            
            Task {
                await processReceiptImage()
            }
        }
        
        @MainActor
        private func processReceiptImage() async {
            guard let imageData = receiptImageData else { return }
            
            isProcessing = true
            defer { isProcessing = false }
            
            do {
                let text = try await imageProcessingService.extractText(from: imageData)
                extractedText = text
                print(text)
                
                // In the future, this is where you would call the LLM service
                // await processWithLLM(text)
                
            } catch {
                processingError = error
                print("Error processing receipt: \(error.localizedDescription)")
            }
        }
        
        // To be implemented in the future
        // private func processWithLLM(_ text: String) async {
        //     // Process with LLM and populate the order fields
        // }
        
        func createOrderItem(modelContext: ModelContext) -> OrderItem? {
            guard !orderNumber.isEmpty, price > 0 else { return nil }
            
            let order = OrderItem(
                orderNumber: orderNumber,
                dateTime: orderDateTime,
                price: price,
                receiptImage: receiptImageData,
                proofImage: nil,
                dishes: dishes.filter { !$0.isEmpty },
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
