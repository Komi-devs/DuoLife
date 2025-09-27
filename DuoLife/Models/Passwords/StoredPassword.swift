import FirebaseFirestore

struct StoredPassword: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String       // e.g. “Twitter”
    var username: String
    var password: String    // Consider encrypting before saving
    var categoryId: String
}
