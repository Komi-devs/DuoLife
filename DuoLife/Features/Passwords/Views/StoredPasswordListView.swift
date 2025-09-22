import SwiftUI

struct StoredPasswordListView: View {
    let category: PasswordCategory
    
    @EnvironmentObject var masterManager: MasterPasswordManager
    @StateObject private var viewModel: StoredPasswordListViewModel

    init(category: PasswordCategory) {
        self.category = category
        // VM will be initialized later once we have the environment manager
        _viewModel = StateObject(
            wrappedValue: StoredPasswordListViewModel(
                categoryId: category.id ?? "",
                masterManager: MasterPasswordManager() // temporary placeholder
            )
        )
    }

    var body: some View {
        List {
            ForEach(viewModel.passwords) { item in
                VStack(alignment: .leading) {
                    Text(item.title).font(.headline)
                    Text("Username: \(item.username)")
                    Text("Password: \(item.password)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: viewModel.deletePassword)
        }
        .navigationTitle(category.name)
        .toolbar {
            Button { viewModel.showAddSheet = true } label: {
                Label("Add", systemImage: "plus")
            }
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddStoredPasswordView(viewModel: viewModel)
        }
        .onAppear {
            // inject the real manager from environment if not already set
            if viewModel.masterManager !== masterManager {
                viewModel.masterManager = masterManager
            }
            viewModel.loadPasswords()
        }
        .onChange(of: masterManager.masterPassword) { _ in
            viewModel.loadPasswords()
        }
    }
}
