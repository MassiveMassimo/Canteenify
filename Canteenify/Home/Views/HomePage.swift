import SwiftUI
import SwiftData

struct HomePage: View {
    @Environment(\.modelContext) private var modelContext
    @State private var homeViewModel = HomeViewModel()
    @Namespace private var namespace
    
    @Query(sort: \OrderItem.orderNumberTail, order: .reverse, animation: .default) var orders: [OrderItem]
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    Section {
                        ForEach(orders) { order in
                            ZStack {
                                Receipt(order: order, namespace: namespace)
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
            }
            BottomActions(viewModel: homeViewModel)
        }
        .processingOverlay(isShowing: homeViewModel.isProcessing, imageData: homeViewModel.receiptImageData)
        .onAppear {
            homeViewModel.setModelContext(modelContext)
        }
    }
}

#Preview {
    HomePage()
        .modelContainer(DataController.previewContainer)
}
