import SwiftUI

struct AddGroceryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var quantity = 1
    @State private var isFood = true
    @State private var expiration: Date? = nil

    var onAdd: (GroceryItem) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                Toggle("Is Food", isOn: $isFood)
                DatePicker(
                    "Expiration",
                    selection: Binding<Date>(
                        get: { expiration ?? Date() },            // fallback if nil
                        set: { expiration = $0 }                  // update optional
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            .navigationTitle("Add Grocery")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = GroceryItem(
                            name: name,
                            quantity: quantity,
                            isFood: isFood,
                            expirationDate: expiration
                        )
                        onAdd(item)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
