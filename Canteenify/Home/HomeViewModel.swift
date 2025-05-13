import SwiftUI
import SwiftData

extension HomePage {
    @Observable
    class HomeViewModel {
        // MARK: - Dependencies
        private let imageProcessingService: ImageProcessingService
        private let llmService: LLMServiceProtocol
        private var modelContext: ModelContext?
        
        // MARK: - State
        var receiptImageData: Data?
        var extractedText: String?
        var isProcessing: Bool = false
        var processingError: Error?
        
        var llmResponse: String?
        var isProcessingLLM: Bool = false
        var llmError: Error?
        
        // MARK: - OrderItem fields
        var orderNumber: String = ""
        var orderDateTime: Date = Date()
        var price: Double = 0.0
        var dishes: [Dishes] = []
        var restaurantName: String = ""
        var paymentMethod: String = ""
        
        // MARK: - Creation Result
        var createdOrder: OrderItem?
        var orderCreationError: String?
        
        // MARK: - Initialization
        init(
            imageProcessingService: ImageProcessingService = VisionImageProcessingService(),
            llmService: LLMServiceProtocol = GeminiLLMService.createWithDefaultAPIKey() ?? LLMService()
        ) {
            self.imageProcessingService = imageProcessingService
            self.llmService = llmService
        }
        
        // MARK: - Set Model Context
        func setModelContext(_ context: ModelContext) {
            self.modelContext = context
        }
        
        // MARK: - Actions
        func handleReceiptImageSelected(_ imageData: Data) {
            receiptImageData = imageData
            extractedText = nil
            llmResponse = nil
            processingError = nil
            llmError = nil
            createdOrder = nil
            orderCreationError = nil
            
            // Reset order fields
            orderNumber = ""
            orderDateTime = Date()
            price = 0.0
            dishes = []
            restaurantName = ""
            paymentMethod = ""
            
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
                
                isProcessingLLM = true
                
                let prompt = """
                Extract the following information from this receipt and format your response as a JSON object:
                - Order Number: Extract just the order number (format: POS-XXXXXX-XXX or similar)
                - Date and Time: Extract the date and time
                - Total Price: Extract only the numeric value
                - Restaurant Name: Extract the full restaurant name
                - Items: For each item, extract the name and price
                - Payment Method: Extract the payment method
                
                Format your response as a valid JSON object like this:
                {
                  "orderNumber": "POS-080425-110",
                  "dateTime": "08/04/2025 12:57",
                  "totalPrice": 20000,
                  "restaurantName": "Mama Djempol Binong",
                  "items": [
                    {"name": "Nasi Putih", "price": 4000},
                    {"name": "Tahu Tauco", "price": 5000},
                    {"name": "Daging Ayam Lada Hitam", "price": 11000}
                  ],
                  "paymentMethod": "Qris Mandiri"
                }
                
                Only output the JSON object with no additional text or explanation.
                Here is the receipt text:
                \(text)
                """
                
                llmResponse = await llmService.generateResponse(from: prompt)
                isProcessingLLM = false
                
                if let response = llmResponse {
                    print("LLM Response:")
                    print(response)
                    
                    // Parse the JSON response
                    if parseJsonResponse(response) {
                        // Auto-create the order item if parsing succeeded and we have a model context
                        if let context = modelContext {
                            createOrderItem(modelContext: context)
                        } else {
                            print("Warning: No model context available to create order")
                        }
                    }
                } else {
                    print("No LLM response generated")
                }
                
            } catch {
                processingError = error
                print("Error processing receipt: \(error.localizedDescription)")
            }
            
            isProcessing = false
        }
        
        private func parseJsonResponse(_ jsonString: String) -> Bool {
            // Define a structure matching our expected JSON
            struct ReceiptData: Decodable {
                let orderNumber: String
                let dateTime: String
                let totalPrice: Double
                let restaurantName: String
                let items: [Item]
                let paymentMethod: String
                
                struct Item: Decodable {
                    let name: String
                    let price: Double
                }
            }
            
            // Try to get valid JSON first (removing any extra text the LLM might add)
            guard let jsonStart = jsonString.firstIndex(of: "{"),
                  let jsonEnd = jsonString.lastIndex(of: "}") else {
                print("Invalid JSON format")
                return false
            }
            
            let jsonSubstring = jsonString[jsonStart...jsonEnd]
            let validJsonString = String(jsonSubstring)
            
            do {
                let decoder = JSONDecoder()
                let receiptData = try decoder.decode(ReceiptData.self, from: Data(validJsonString.utf8))
                
                // Update our model fields
                self.orderNumber = receiptData.orderNumber
                self.price = receiptData.totalPrice
                self.restaurantName = receiptData.restaurantName
                self.paymentMethod = receiptData.paymentMethod
                
                // Parse date
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy HH:mm"
                if let date = formatter.date(from: receiptData.dateTime) {
                    self.orderDateTime = date
                }
                
                // Convert items to Dishes
                self.dishes = receiptData.items.map { item in
                    Dishes(name: item.name, price: item.price)
                }
                
                print("Successfully parsed JSON to model fields")
                return true
                
            } catch {
                print("Error decoding JSON: \(error)")
                return false
            }
        }
        
        @discardableResult
        func createOrderItem(modelContext: ModelContext) -> OrderItem? {
            guard !orderNumber.isEmpty, price > 0 else {
                orderCreationError = "Missing required fields: order number or price"
                print(orderCreationError ?? "")
                return nil
            }
            
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
            
            do {
                try modelContext.save()
                createdOrder = order
                print("Order successfully created: \(orderNumber)")
                return order
            } catch {
                orderCreationError = "Failed to save order: \(error.localizedDescription)"
                print(orderCreationError ?? "")
                return nil
            }
        }
    }
}
