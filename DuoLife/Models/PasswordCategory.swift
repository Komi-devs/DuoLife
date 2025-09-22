import FirebaseFirestore

struct PasswordCategory: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
}
