import Foundation
import FirebaseFirestore

class PasswordsService: ObservableObject {
    private let db = Firestore.firestore()
    
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
