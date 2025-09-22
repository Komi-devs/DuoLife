import SwiftUI

struct AddPasswordCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    let onAdd: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Name")) {
                    TextField("e.g. Social, Banking", text: $name)
                }
            }
            .navigationTitle("New Category")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onAdd(name)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
