import Foundation
import Combine

final class OwnedGroceriesViewModel: ObservableObject {
    @Published var items: [GroceryItem] = []
    @Published var showingAddSheet = false

    private let service = GroceriesService()

    // MARK: Load
    func load() {
        print("OwnedGroceriesViewModel.load()")
        service.fetchOwnedGroceries { [weak self] fetched in
            DispatchQueue.main.async {
                print("Fetched \(fetched.count) owned groceries")
                self?.items = fetched
            }
        }
    }

    // MARK: Add
    func add(_ item: GroceryItem) {
        print("Adding owned grocery: \(item.name)")
        service.addOwnedGrocery(item) { [weak self] success in
            if success { self?.load() }
        }
    }

    // MARK: Delete
    func delete(at offsets: IndexSet) {
        print("Deleting owned groceries at offsets \(offsets)")
        for index in offsets {
            let item = items[index]
            service.deleteGrocery(item, fromOwned: true) { [weak self] success in
                guard success else {
                    print("⚠️ Failed to delete owned grocery \(item.id ?? "no id")")
                    return
                }
                DispatchQueue.main.async {
                    self?.items.remove(at: index)
                }
            }
        }
    }

    // MARK: Consume (reduce quantity)
    func consume(_ item: GroceryItem) {
        guard var updated = items.first(where: { $0.id == item.id }) else { return }
        if updated.quantity > 1 {
            updated.quantity -= 1
            print("Consuming one \(updated.name), remaining \(updated.quantity)")
            service.updateGrocery(updated, inOwned: true) { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        if let idx = self?.items.firstIndex(where: { $0.id == updated.id }) {
                            self?.items[idx] = updated
                        }
                    }
                }
            }
        } else {
            // Quantity is 1 → remove completely
            print("Consuming last \(updated.name), deleting item")
            service.deleteGrocery(updated, fromOwned: true) { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    self?.items.removeAll { $0.id == updated.id }
                }
            }
        }
    }
}
