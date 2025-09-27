import Foundation
import FirebaseFirestore

struct Restaurant: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var nationality: String? = nil
    var city: String? = nil
}
