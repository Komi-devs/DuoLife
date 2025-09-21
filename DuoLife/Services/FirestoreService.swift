import Foundation
import FirebaseFirestore

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    
    // Fetch all accounts
    func fetchAccounts(completion: @escaping ([Account]) -> Void) {
        db.collection("accounts").order(by: "createdAt").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else {
                completion([])
                return
            }
            let accounts = docs.compactMap { try? $0.data(as: Account.self) }
            completion(accounts)
        }
    }
    
    // Add new account
    func addAccount(name: String, completion: @escaping (Bool) -> Void) {
        let newAccount = Account(name: name)
        do {
            _ = try db.collection("accounts").addDocument(from: newAccount)
            completion(true)
        } catch {
            print("Error adding account: \(error)")
            completion(false)
        }
    }

    // Fetch transactions for an account
    func fetchTransactions(for accountId: String, completion: @escaping ([Transaction]) -> Void) {
        db.collection("accounts").document(accountId).collection("transactions")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let transactions = docs.compactMap { try? $0.data(as: Transaction.self) }
                completion(transactions)
            }
    }

    // Add transaction
    func addTransaction(to accountId: String, transaction: Transaction, completion: @escaping (Bool) -> Void) {
        do {
            _ = try db.collection("accounts")
                .document(accountId)
                .collection("transactions")
                .addDocument(from: transaction)
            completion(true)
        } catch {
            print("Error adding transaction: \(error)")
            completion(false)
        }
    }
}

