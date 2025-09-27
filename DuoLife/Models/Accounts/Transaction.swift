import FirebaseFirestore

enum TransactionType: String, Codable {
    case income
    case expense
}

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    var amount: Double
    var type: TransactionType
    var date: Date
    var description: String
    var isRecurring: Bool = false
    var recurrence: String? = nil // "monthly" if recurring
}
