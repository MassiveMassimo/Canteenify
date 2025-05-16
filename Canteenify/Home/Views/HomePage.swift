import SwiftUI
import SwiftData

struct HomePage: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ViewModel()
    @Namespace private var namespace
    @State private var selectedFilter: String = "All"
    
    let filterOptions = ["All", "Pending", "Verified", "Mismatched"]
    
    @Query(sort: \OrderItem.orderNumberTail, order: .reverse, animation: .default) var orders: [OrderItem]
    
    var filteredOrders: [OrderItem] {
        switch selectedFilter {
        case "Pending":
            return orders.filter { $0.verificationStatus == .pending }
        case "Verified":
            return orders.filter { $0.verificationStatus == .verified }
        case "Mismatched":
            return orders.filter { $0.verificationStatus == .mismatch }
        default:
            return orders
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filterOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                ZStack {
                    List {
                        Section {
                            ForEach(filteredOrders) { order in
                                ZStack {
                                    Receipt(order: order, viewModel: viewModel, namespace: namespace)
                                        .contentShape(Rectangle())
                                    NavigationLink {
                                        OrderDetailsPage(order: order)
                                            .navigationTransition(.zoom(sourceID: order.id, in: namespace))
                                    } label: {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                }
                                .tint(.black)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        // Add actual delete functionality
                                        modelContext.delete(order)
                                        try? modelContext.save()
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                            }
                            Spacer()
                                .frame(height: 120)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Canteenify")
                    .animation(.default, value: selectedFilter)
                    BottomActions(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .processingOverlay(isShowing: viewModel.isProcessing, imageData: viewModel.receiptImageData)
    }
}

#Preview {
    HomePage()
        .modelContainer(DataController.previewContainer)
}
