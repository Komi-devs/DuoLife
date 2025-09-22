import Foundation
import Combine

final class PasswordCategoryListViewModel: ObservableObject {
    @Published var categories: [PasswordCategory] = []
    @Published var showAddSheet = false

    private let firestore = FirestoreService()

    func loadCategories() {
        firestore.fetchPasswordCategories { [weak self] cats in
            DispatchQueue.main.async {
                self?.categories = cats
            }
        }
    }

    func addCategory(_ name: String) {
        firestore.addPasswordCategory(name) { [weak self] success in
            if success { self?.loadCategories() }
        }
    }

    func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            firestore.deletePasswordCategory(category) { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        self?.categories.remove(at: index)
                    }
                }
            }
        }
    }
}
