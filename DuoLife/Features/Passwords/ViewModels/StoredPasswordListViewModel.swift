import Foundation
import Combine

final class StoredPasswordListViewModel: ObservableObject {
    @Published var passwords: [StoredPassword] = []
    @Published var showAddSheet = false

    let categoryId: String
    var masterManager: MasterPasswordManager
    private let firestore = PasswordsService()

    init(categoryId: String, masterManager: MasterPasswordManager) {
        self.categoryId = categoryId
        self.masterManager = masterManager
        print("ViewModel init – categoryId: \(categoryId), masterManager set")
    }

    // MARK: Load
    func loadPasswords() {
        print("loadPasswords() called for categoryId: \(categoryId)")

        firestore.fetchStoredPasswords(for: categoryId) { [weak self] fetched in
            guard let self = self else {
                print("loadPasswords: self deallocated")
                return
            }

            print("fetchStoredPasswords returned \(fetched.count) items")

            let decrypted = fetched.compactMap { item -> StoredPassword? in
                guard let data = Data(base64Encoded: item.password),
                      let plain = decryptPassword(data, withMaster: self.masterManager.masterPassword)
                else {
                    print("⚠️ Decryption failed for item \(item.id ?? "no id")")
                    return nil
                }
                var copy = item
                copy.password = plain
                return copy
            }

            // ✅ Update the published property on the main thread
            DispatchQueue.main.async {
                print("Assigning \(decrypted.count) decrypted items to self.passwords")
                self.passwords = decrypted
            }
        }
    }

    // MARK: Delete
    func deletePassword(at offsets: IndexSet) {
        print("deletePassword called for indexes: \(offsets)")
        for index in offsets {
            let item = passwords[index]
            print("Deleting item \(item.id ?? "no id") from category \(categoryId)")
            firestore.deleteStoredPassword(item, from: categoryId) { [weak self] success in
                guard success else {
                    print("⚠️ Failed to delete item \(item.id ?? "no id")")
                    return
                }
                DispatchQueue.main.async {
                    print("Item \(item.id ?? "no id") deleted locally")
                    self?.passwords.remove(at: index)
                }
            }
        }
    }

    // MARK: Add
    func addPassword(_ password: StoredPassword, completion: @escaping () -> Void) {
        guard let encrypted = encryptPassword(password.password,
                                              withMaster: masterManager.masterPassword)
        else {
            print("⚠️ Encryption failed")
            return
        }

        var encryptedItem = password
        // ✅ Convert binary to Base64 text for Firestore
        encryptedItem.password = encrypted.base64EncodedString()

        firestore.addStoredPassword(encryptedItem, to: categoryId) { [weak self] success in
            if success {
                self?.loadPasswords()
                completion()
            }
        }
    }

}
