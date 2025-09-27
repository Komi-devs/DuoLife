import Foundation
import Combine

final class GroceryListViewModel: ObservableObject {
    @Published var items: [GroceryItem] = []
    @Published var showingAddSheet = false

    private let service = GroceriesService()

    // MARK: Load
    func load() {
        print("GroceryListViewModel.load()")
        service.fetchShoppingList { [weak self] fetched in
            DispatchQueue.main.async {
                print("Fetched \(fetched.count) shopping items")
                self?.items = fetched
            }
        }
    }

    // MARK: Add
    func add(_ item: GroceryItem) {
        print("Adding grocery to shopping list: \(item.name)")
        service.addToShoppingList(item) { [weak self] success in
            if success { self?.load() }
        }
    }

    // MARK: Delete
    func delete(at offsets: IndexSet) {
        print("Deleting groceries at offsets \(offsets)")
        for index in offsets {
            let item = items[index]
            service.deleteGrocery(item, fromOwned: false) { [weak self] success in
                guard success else {
                    print("⚠️ Failed to delete grocery \(item.id ?? "no id")")
                    return
                }
                DispatchQueue.main.async {
                    self?.items.remove(at: index)
                }
            }
        }
    }

    // MARK: Toggle Purchased
    func togglePurchased(_ item: GroceryItem) {
        guard var updated = items.first(where: { $0.id == item.id }) else { return }
        updated.purchased.toggle()
        print("Toggling purchased to \(updated.purchased) for \(updated.name)")
        service.updateGrocery(updated, inOwned: false) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    if let idx = self?.items.firstIndex(where: { $0.id == updated.id }) {
                        self?.items[idx] = updated
                    }
                }
            }
        }
    }

    // MARK: Validate
    func validatePurchases() {
        print("Validating purchases…")
        service.validatePurchases { [weak self] result in
            switch result {
            case .success:
                print("Purchased items moved to owned groceries")
                self?.load()
            case .failure(let error):
                print("⚠️ Failed to validate purchases: \(error)")
            }
        }
    }
}
