import Foundation
import FirebaseFirestore

/// A single grocery item
struct GroceryItem: Identifiable, Codable {
    @DocumentID var id: String?           // Firestore document ID
    var name: String                      // e.g. "Milk"
    var quantity: Int = 1                 // default 1
    var isFood: Bool = true               // is consumable
    var expirationDate: Date? = nil       // optional
    var purchased: Bool = false           // for the shopping list checkmark
}
