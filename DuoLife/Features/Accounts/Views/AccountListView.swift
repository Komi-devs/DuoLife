import SwiftUI

struct AccountListView: View {
    @StateObject private var viewModel = AccountListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.accounts) { account in
                    NavigationLink(destination: TransactionListView(account: account)) {
                        Text(account.name)
                    }
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                Button(action: { viewModel.showAddSheet = true }) {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddAccountView { name in
                    viewModel.addAccount(name: name)
                }
            }
            .onAppear {
                viewModel.loadAccounts()
            }
        }
    }
}

