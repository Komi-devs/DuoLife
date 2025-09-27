import SwiftUI

struct OwnedGroceriesView: View {
    @EnvironmentObject var viewModel: OwnedGroceriesViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(item.name) ×\(item.quantity)")
                            .font(.headline)

                        if let exp = item.expirationDate {
                            Text("Exp: \(exp.formatted(date: .numeric, time: .omitted))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // ✅ Show whether it's food or not
                        Text(item.isFood ? "Food" : "Non-Food")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Consume one unit
                    Button {
                        viewModel.consume(item)
                    } label: {
                        Label("Consume", systemImage: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                }
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Owned Groceries")
        .toolbar {
            Button {
                viewModel.showingAddSheet = true
            } label: {
                Label("Add", systemImage: "plus")
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
