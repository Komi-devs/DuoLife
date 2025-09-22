import Foundation
import Combine

final class StoredPasswordListViewModel: ObservableObject {
    @Published var passwords: [StoredPassword] = []
    @Published var showAddSheet = false

    let categoryId: String
    var masterManager: MasterPasswordManager
    private let firestore = FirestoreService()

    init(categoryId: String, masterManager: MasterPasswordManager) {
        self.categoryId = categoryId
        self.masterManager = masterManager
    }

    // MARK: Load
    func loadPasswords() {
        firestore.fetchStoredPasswords(for: categoryId) { [weak self] fetched in
            guard let self = self else { return }

            let decrypted = fetched.compactMap { item -> StoredPassword? in
                guard let data = item.password.data(using: .utf8),
                      let plain = decryptPassword(data, withMaster: self.masterManager.masterPassword)
                else { return nil }

                var copy = item
                copy.password = plain
                return copy
            }

            DispatchQueue.main.async {
                self.passwords = decrypted
            }
        }
    }

    // MARK: Delete
    func deletePassword(at offsets: IndexSet) {
        for index in offsets {
            let item = passwords[index]
            firestore.deleteStoredPassword(item, from: categoryId) { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    self?.passwords.remove(at: index)
                }
            }
        }
    }

    // MARK: Add
    func addPassword(_ password: StoredPassword, completion: @escaping () -> Void) {
        guard let encrypted = encryptPassword(password.password,
                                              withMaster: masterManager.masterPassword)
        else { return }

        var encryptedItem = password
        encryptedItem.password = String(data: encrypted, encoding: .utf8) ?? ""

        firestore.addStoredPassword(encryptedItem, to: categoryId) { [weak self] success in
            if success {
                self?.loadPasswords()
                completion()
            }
        }
    }
}
