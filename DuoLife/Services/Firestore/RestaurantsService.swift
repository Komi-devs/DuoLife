import Foundation
import FirebaseFirestore

class RestaurantsService: ObservableObject {
    private let db = Firestore.firestore()

    // MARK: Restaurants

    func fetchRestaurants(completion: @escaping ([Restaurant]) -> Void) {
        db.collection("restaurants")
            .order(by: "name")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let restaurants = docs.compactMap { try? $0.data(as: Restaurant.self) }
                completion(restaurants)
            }
    }

    func addRestaurant(_ restaurant: Restaurant, completion: @escaping (Bool) -> Void) {
        do {
            _ = try db.collection("restaurants").addDocument(from: restaurant)
            completion(true)
        } catch {
            print("Error adding restaurant: \(error)")
            completion(false)
        }
    }

    func deleteRestaurant(_ restaurant: Restaurant, completion: @escaping (Bool) -> Void) {
        guard let id = restaurant.id else { completion(false); return }

        let restaurantRef = db.collection("restaurants").document(id)

        // Delete notes first
        restaurantRef.collection("notes").getDocuments { snapshot, error in
            let batch = self.db.batch()
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { batchErr in
                if let batchErr = batchErr {
                    print("Error deleting notes: \(batchErr)")
                }
                restaurantRef.delete { err in
                    completion(err == nil)
                }
            }
        }
    }

    // MARK: Notes

    func fetchNotes(for restaurantId: String, completion: @escaping ([Note]) -> Void) {
        db.collection("restaurants")
            .document(restaurantId)
            .collection("notes")
            .order(by: "createdAt", descending: false)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                let notes = docs.compactMap { try? $0.data(as: Note.self) }
                completion(notes)
            }
    }

    func addNote(_ note: Note, completion: @escaping (Bool) -> Void) {
        let restaurantId = note.restaurantId
        
        do {
            _ = try db.collection("restaurants")
                .document(restaurantId)
                .collection("notes")
                .addDocument(from: note)
            completion(true)
        } catch {
            print("Error adding note: \(error)")
            completion(false)
        }
    }
}
