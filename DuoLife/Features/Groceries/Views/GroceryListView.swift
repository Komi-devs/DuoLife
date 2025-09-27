import SwiftUI

struct GroceryListView: View {
    @EnvironmentObject var viewModel: GroceryListViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                HStack {
                    // Checkmark to toggle purchase
                    Button(action: { viewModel.togglePurchased(item) }) {
                        Image(systemName: item.purchased ? "checkmark.circle.fill"
                                                         : "circle")
                            .foregroundColor(item.purchased ? .green : .gray)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading) {
                        Text("\(item.name) ×\(item.quantity)")
                            .font(.headline)
                        if let exp = item.expirationDate {
                            Text("Exp: \(exp.formatted(date: .numeric, time: .omitted))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Text(item.isFood ? "Food" : "Non-Food")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Shopping List")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Validate") { viewModel.validatePurchases() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showingAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            AddGroceryItemView { newItem in
                viewModel.add(newItem)
            }
        }
        .onAppear { viewModel.load() }
    }
}
