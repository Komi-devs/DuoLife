import SwiftUI

struct PasswordCategoryListView: View {
    @StateObject private var viewModel = PasswordCategoryListViewModel()

    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Password Categories")
        }
    }
}

