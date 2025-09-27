import Foundation
import FirebaseFirestore

struct Note: Identifiable, Codable {
    @DocumentID var id: String?
    var restaurantId: String
    var author: String
    var content: String
    var createdAt: Date = Date()
}
