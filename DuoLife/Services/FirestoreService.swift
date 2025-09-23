import Foundation
import FirebaseFirestore

class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    
    // MARK: - Accounts
    
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
    
    // MARK: - Transactions

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
    
    // MARK: - Password Categories
        
    func fetchPasswordCategories(completion: @escaping ([PasswordCategory]) -> Void) {
        db.collection("passwordCategories")
            .order(by: "name")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let categories = docs.compactMap { try? $0.data(as: PasswordCategory.self) }
                completion(categories)
            }
    }
    
    func addPasswordCategory(_ name: String, completion: @escaping (Bool) -> Void) {
        let newCategory = PasswordCategory(name: name)
        do {
            _ = try db.collection("passwordCategories").addDocument(from: newCategory)
            completion(true)
        } catch {
            print("Error adding category: \(error)")
            completion(false)
        }
    }
    
    func deletePasswordCategory(_ category: PasswordCategory, completion: @escaping (Bool) -> Void) {
        guard let id = category.id else {
            completion(false)
            return
        }
        
        let catRef = db.collection("passwordCategories").document(id)
        
        // Delete all StoredPasswords first
        catRef.collection("storedPasswords").getDocuments { snapshot, error in
            let batch = self.db.batch()
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { batchError in
                if let batchError = batchError {
                    print("Error deleting passwords: \(batchError)")
                }
                // Delete the category itself
                catRef.delete { err in
                    completion(err == nil)
                }
            }
        }
    }
    
    // MARK: - StoredPasswords
    
    func fetchStoredPasswords(for categoryId: String, completion: @escaping ([StoredPassword]) -> Void) {
        db.collection("passwordCategories")
            .document(categoryId)
            .collection("storedPasswords")
            .order(by: "title")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let passwords = docs.compactMap { try? $0.data(as: StoredPassword.self) }
                completion(passwords)
            }
    }
    
    func addStoredPassword(_ password: StoredPassword, to categoryId: String, completion: @escaping (Bool) -> Void) {
        do {
            _ = try db.collection("passwordCategories")
                .document(categoryId)
                .collection("storedPasswords")
                .addDocument(from: password)
            completion(true)
        } catch {
            print("Error adding password: \(error)")
            completion(false)
        }
    }
    
    func deleteStoredPassword(_ password: StoredPassword, from categoryId: String, completion: @escaping (Bool) -> Void) {
        guard let id = password.id else {
            completion(false)
            return
        }
        db.collection("passwordCategories")
            .document(categoryId)
            .collection("storedPasswords")
            .document(id)
            .delete { err in
                completion(err == nil)
            }
    }
    
    func deleteAllPasswordData(completion: @escaping (Result<Void,Error>) -> Void) {
        let categoriesRef = db.collection("passwordCategories")

        categoriesRef.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let batch = self.db.batch()

            // For each category, delete all storedPasswords and the category doc itself
            snapshot?.documents.forEach { categoryDoc in
                let storedPasswordsRef = categoryDoc.reference.collection("storedPasswords")
                storedPasswordsRef.getDocuments { pwdSnapshot, pwdError in
                    // If there’s an error fetching a subcollection we still try to continue
                    pwdSnapshot?.documents.forEach { pwdDoc in
                        batch.deleteDocument(pwdDoc.reference)
                    }
                    batch.deleteDocument(categoryDoc.reference)

                    // After processing the last category, commit the batch
                    // (simple approach: commit after all loops finish)
                }
            }

            // Commit after a small async delay to let all inner gets complete.
            // For large datasets you might want a DispatchGroup instead.
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                batch.commit { commitError in
                    if let commitError = commitError {
                        completion(.failure(commitError))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}

