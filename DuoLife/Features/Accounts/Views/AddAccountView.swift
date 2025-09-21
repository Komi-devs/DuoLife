import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    
    var onAdd: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Name")) {
                    TextField("e.g. Main, Savings", text: $name)
                }
            }
            .navigationTitle("New Account")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onAdd(name)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

