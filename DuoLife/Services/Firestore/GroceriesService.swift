import Foundation
import FirebaseFirestore

/// Firestore CRUD service for the Groceries module.
final class GroceriesService: ObservableObject {
    private let db = Firestore.firestore()
    
    // MARK: - Collections
    private var shoppingListRef: CollectionReference {
        db.collection("groceryList")        // planned purchases
    }
    private var ownedGroceriesRef: CollectionReference {
        db.collection("ownedGroceries")     // groceries you already have
    }
    
    // MARK: - Fetch
    
    /// Fetch all items currently in the shopping list.
    func fetchShoppingList(completion: @escaping ([GroceryItem]) -> Void) {
        shoppingListRef
            .order(by: "name")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let items = docs.compactMap { try? $0.data(as: GroceryItem.self) }
                completion(items)
            }
    }
    
    /// Fetch all items currently owned.
    func fetchOwnedGroceries(completion: @escaping ([GroceryItem]) -> Void) {
        ownedGroceriesRef
            .order(by: "name")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let items = docs.compactMap { try? $0.data(as: GroceryItem.self) }
                completion(items)
            }
    }
    
    // MARK: - Add / Update
    
    /// Add a new item to the shopping list.
    func addToShoppingList(_ item: GroceryItem, completion: @escaping (Bool) -> Void) {
        do {
            _ = try shoppingListRef.addDocument(from: item)
            completion(true)
        } catch {
            print("Error adding grocery to shopping list: \(error)")
            completion(false)
        }
    }
    
    /// Add a new owned grocery item.
    func addOwnedGrocery(_ item: GroceryItem, completion: @escaping (Bool) -> Void) {
        do {
            _ = try ownedGroceriesRef.addDocument(from: item)
            completion(true)
        } catch {
            print("Error adding owned grocery: \(error)")
            completion(false)
        }
    }
    
    /// Update an existing grocery (works for either list).
    func updateGrocery(_ item: GroceryItem, inOwned: Bool, completion: @escaping (Bool) -> Void) {
        guard let id = item.id else {
            completion(false)
            return
        }
        let ref = inOwned ? ownedGroceriesRef.document(id) : shoppingListRef.document(id)
        do {
            try ref.setData(from: item, merge: true)
            completion(true)
        } catch {
            print("Error updating grocery: \(error)")
            completion(false)
        }
    }
    
    // MARK: - Delete
    
    func deleteGrocery(_ item: GroceryItem, fromOwned: Bool, completion: @escaping (Bool) -> Void) {
        guard let id = item.id else {
            completion(false)
            return
        }
        let ref = fromOwned ? ownedGroceriesRef.document(id) : shoppingListRef.document(id)
        ref.delete { err in
            completion(err == nil)
        }
    }
    
    // MARK: - Bulk Ops
    
    /// Move all purchased (checked) groceries from the shopping list to the owned list, then delete them from the shopping list.
    func validatePurchases(completion: @escaping (Result<Void, Error>) -> Void) {
        shoppingListRef.whereField("purchased", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let docs = snapshot?.documents, !docs.isEmpty else {
                    completion(.success(())) // nothing to move
                    return
                }
                
                let batch = self.db.batch()
                
                docs.forEach { doc in
                    do {
                        if let item = try? doc.data(as: GroceryItem.self) {
                            let newRef = self.ownedGroceriesRef.document()
                            try batch.setData(from: item, forDocument: newRef)
                        }
                        batch.deleteDocument(doc.reference)
                    } catch {
                        print("Error copying grocery \(doc.documentID): \(error)")
                    }
                }
                
                batch.commit { commitErr in
                    if let commitErr = commitErr {
                        completion(.failure(commitErr))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    /// Remove every grocery document from both collections (for a full reset).
    func deleteAllGroceries(completion: @escaping (Result<Void, Error>) -> Void) {
        let batch = db.batch()
        let group = DispatchGroup()
        
        func queueDelete(_ ref: CollectionReference) {
            group.enter()
            ref.getDocuments { snap, err in
                if let err = err {
                    print("Error fetching for delete: \(err)")
                    group.leave()
                    return
                }
                snap?.documents.forEach { batch.deleteDocument($0.reference) }
                group.leave()
            }
        }
        
        queueDelete(shoppingListRef)
        queueDelete(ownedGroceriesRef)
        
        group.notify(queue: .global()) {
            batch.commit { commitErr in
                if let commitErr = commitErr {
                    completion(.failure(commitErr))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
