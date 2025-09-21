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
    
    // Delete an account and all its transactions (if you want to clean subcollection)
    func deleteAccount(_ account: Account, completion: @escaping (Bool) -> Void) {
        guard let id = account.id else {
            completion(false)
            return
        }

        // If you also want to delete transactions inside the subcollection:
        let accountRef = db.collection("accounts").document(id)
        accountRef.collection("transactions").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else {
                // even if no transactions, still delete account
                accountRef.delete { err in
                    completion(err == nil)
                }
                return
            }
            // batch delete all transactions first
            let batch = self.db.batch()
            for doc in docs {
                batch.deleteDocument(doc.reference)
            }
            batch.commit { batchErr in
                if let batchErr = batchErr {
                    print("Error deleting transactions: \(batchErr)")
                }
                // finally delete the account itself
                accountRef.delete { err in
                    completion(err == nil)
                }
            }
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

