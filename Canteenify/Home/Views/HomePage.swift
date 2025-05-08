import SwiftUI
import SwiftData

struct HomePage: View {
    @Environment(\.modelContext) private var modelContext
    @State private var homeViewModel = HomeViewModel()
    @Query(sort: \OrderItem.orderNumberTail, order: .reverse, animation: .default) var orders: [OrderItem]
    
    @State private var tappedOrder: OrderItem?
    
    var body: some View {
        ZStack {
//            NavigationStack {
                List {
                    Section {
                        ForEach(orders) { order in
                            Button {
                                tappedOrder = order
                            } label: {
                                Receipt(order: order)
                            }
                            .tint(.black)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    print("deleting order \(order.id)")
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
                .listStyle(.plain)
//                .navigationDestination(item: $tappedOrder) { order in
//                    Text("Order #\(order.orderNumberTail)")
//                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 2) {
                            Text("Canteenify")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("\(Date.now.formatted(date: .abbreviated, time: .omitted)) | \(orders.count) orders")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .overlay {
                    if homeViewModel.isProcessing {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Processing receipt...")
                                .font(.headline)
                                .padding(.top)
                        }
                        .frame(width: 200, height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .shadow(radius: 10)
                    }
                }
//            }
            BottomActions(viewModel: homeViewModel)
        }
    }
}

#Preview {
    HomePage()
        .modelContainer(DataController.previewContainer)
}
