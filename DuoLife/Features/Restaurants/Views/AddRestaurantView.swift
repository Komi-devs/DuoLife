import SwiftUI

struct AddRestaurantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var nationality = ""
    @State private var city = ""

    var onAdd: (Restaurant) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Nationality", text: $nationality)
                TextField("City", text: $city)
            }
            .navigationTitle("Add Restaurant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let restaurant = Restaurant(
                            name: name,
                            nationality: nationality.isEmpty ? nil : nationality,
                            city: city.isEmpty ? nil : city
                        )
                        onAdd(restaurant)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
