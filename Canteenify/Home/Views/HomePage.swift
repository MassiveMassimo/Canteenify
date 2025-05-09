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
                                    print("deleting order \(order.id)")
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
                //                .toolbar {
                //                    ToolbarItem(placement: .principal) {
                //                        VStack(spacing: 2) {
                //                            Text("Canteenify")
                //                                .font(.title3)
                //                                .fontWeight(.bold)
                //                                .multilineTextAlignment(.center)
                //
                //                            Text("\(Date.now.formatted(date: .abbreviated, time: .omitted)) | \(orders.count) orders")
                //                                .font(.subheadline)
                //                                .foregroundStyle(.secondary)
                //                        }
                //                    }
                //                }
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
            }
            BottomActions(viewModel: homeViewModel)
        }
    }
}

#Preview {
    HomePage()
        .modelContainer(DataController.previewContainer)
}
