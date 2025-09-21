import Foundation

class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var balance: Double = 0.0
    @Published var showAddSheet = false
    
    private let firestore = FirestoreService()
    
    func loadTransactions(for accountId: String) {
        firestore.fetchTransactions(for: accountId) { txs in
            DispatchQueue.main.async {
                self.transactions = txs
                self.calculateBalance()
            }
        }
    }
    
    private func calculateBalance() {
        balance = transactions.reduce(0.0) { result, tx in
            switch tx.type {
            case .income:
                return result + tx.amount
            case .expense:
                return result - tx.amount
            }
        }
    }
}

