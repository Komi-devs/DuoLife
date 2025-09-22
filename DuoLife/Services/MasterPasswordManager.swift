import Foundation
import CryptoKit
import KeychainAccess

class MasterPasswordManager: ObservableObject {
    private let keychain = Keychain(service: "com.duolife.app")
    private let masterPasswordKey = "masterPasswordHash"

    @Published var isAuthenticated = false
    
    // MARK: - First-time setup
    func setMasterPassword(_ password: String) throws {
        let hash = sha256(password)
        try keychain.set(hash, key: masterPasswordKey)
    }

    // MARK: - Authentication
    func authenticate(_ password: String) -> Bool {
        guard let storedHash = try? keychain.get(masterPasswordKey) else {
            return false
        }
        return storedHash == sha256(password)
    }

    // MARK: - Update password
    func updateMasterPassword(oldPassword: String, newPassword: String) throws -> Bool {
        if authenticate(oldPassword) {
            try setMasterPassword(newPassword)
            return true
        }
        return false
    }

    // MARK: - Helper
    private func sha256(_ string: String) -> String {
        let data = Data(string.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Check if master password exists
    func hasMasterPassword() -> Bool {
        return (try? keychain.get(masterPasswordKey)) != nil
    }
    
    func removeMasterPasswordOnly() {
        try? keychain.remove(masterPasswordKey)
    }

    func removeAllData() {
        try? keychain.remove(masterPasswordKey)
        // Add calls here to delete any locally cached encrypted records
        // and, if desired, trigger Firebase deletion of the user’s data.
    }
}
