import SwiftUI

struct TransactionListView: View {
    var account: Account
    @StateObject private var viewModel = TransactionListViewModel()

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Balance")
                        .font(.headline)
                    Spacer()
                    Text("\(viewModel.balance, specifier: "%.2f") €")
                        .foregroundColor(viewModel.balance >= 0 ? .green : .red)
                        .bold()
                }
            }

            ForEach(viewModel.transactions) { tx in
                VStack(alignment: .leading) {
                    Text(tx.description)
                        .font(.headline)
                    Text("\(tx.amount, specifier: "%.2f") € — \(tx.date.formatted())")
                        .font(.subheadline)
                }
                .foregroundColor(tx.type == .expense ? .red : .green)
            }
        }
        .navigationTitle(account.name)
        .toolbar {
            Button(action: {
                viewModel.showAddSheet = true
            }) {
                Label("Add", systemImage: "plus")
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddTransactionView(accountId: account.id ?? "") {
                viewModel.loadTransactions(for: account.id ?? "")
            }
        }
        .onAppear {
            viewModel.loadTransactions(for: account.id ?? "")
        }
    }
}
