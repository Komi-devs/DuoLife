import SwiftUI

struct AddStoredPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StoredPasswordListViewModel

    @State private var title = ""
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Info")) {
                    TextField("Title", text: $title)
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                }
            }
            .navigationTitle("New Password")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newItem = StoredPassword(
                            title: title,
                            username: username,
                            password: password, // plaintext; viewModel encrypts
                            categoryId: viewModel.categoryId
                        )
                        viewModel.addPassword(newItem) { dismiss() }
                    }
                    .disabled(title.isEmpty || username.isEmpty || password.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
