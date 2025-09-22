import SwiftUI

struct PasswordCategoryListView: View {
    @EnvironmentObject private var masterManager: MasterPasswordManager
    @StateObject private var viewModel = PasswordCategoryListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.categories) { category in
                    NavigationLink(
                        destination: StoredPasswordListView(category: category)
                            .environmentObject(masterManager)
                    ) {
                        Text(category.name)
                    }
                }
                .onDelete(perform: viewModel.deleteCategory)
            }
            .navigationTitle("Password Categories")
            .toolbar {
                Button {
                    viewModel.showAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddPasswordCategoryView { name in
                    viewModel.addCategory(name)
                }
            }
            .onAppear { viewModel.loadCategories() }
        }
    }
}
