import Foundation
import CryptoKit
import KeychainAccess
import Combine

/// Central authority for everything related to the master password.
/// Inject a single instance with `.environmentObject` and read it anywhere.
final class MasterPasswordManager: ObservableObject {
    private let keychain = Keychain(service: "com.duolife.app")
    private let masterPasswordKey = "masterPasswordHash"

    /// The current plain-text master password kept only in memory for this run.
    @Published private(set) var masterPassword: String = ""

    /// Whether the user is authenticated for the current session.
    @Published private(set) var isAuthenticated: Bool = false

    /// Whether a master password has ever been set (persisted in Keychain).
    @Published private(set) var hasExistingMaster: Bool = false

    // MARK: - Init

    init() {
        // Check immediately whether a master password already exists in Keychain.
        self.hasExistingMaster = (try? keychain.get(masterPasswordKey)) != nil
    }

    // MARK: - Public API

    /// First-time setup: stores the hash and keeps the plain password in memory.
    func setMasterPassword(_ password: String) throws {
        let hash = sha256(password)
        try keychain.set(hash, key: masterPasswordKey)
        masterPassword = password
        isAuthenticated = true
        hasExistingMaster = true
    }

    /// Verifies a password, and if valid, keeps it in memory for this session.
    @discardableResult
    func authenticate(_ password: String) -> Bool {
        guard let storedHash = try? keychain.get(masterPasswordKey) else {
            return false
        }
        let ok = storedHash == sha256(password)
        if ok {
            masterPassword = password
            isAuthenticated = true
        }
        return ok
    }
    
    // Call this to explicitly sign the user out
    func signOut() {
        masterPassword = ""
        isAuthenticated = false
    }
    
    func hasMasterPassword() -> Bool {
        return (try? keychain.get(masterPasswordKey)) != nil
    }

    /// Change the master password if the old one is correct.
    @discardableResult
    func updateMasterPassword(oldPassword: String, newPassword: String) throws -> Bool {
        guard authenticate(oldPassword) else { return false }
        try setMasterPassword(newPassword)
        return true
    }

    /// Clears only the stored hash (keeps encrypted data) and logs out.
    func removeMasterPasswordOnly() {
        try? keychain.remove(masterPasswordKey)
        resetSession()
        hasExistingMaster = false
    }

    /// Wipes everything, including all encrypted records if you add that logic.
    func removeAllData() {
        try? keychain.remove(masterPasswordKey)
        // TODO: also clear any local caches or call Firebase deletion.
        resetSession()
        hasExistingMaster = false
    }

    /// Logs out without touching persistent storage.
    func logout() {
        resetSession()
    }

    // MARK: - Helpers

    private func resetSession() {
        masterPassword = ""
        isAuthenticated = false
    }

    private func sha256(_ string: String) -> String {
        let data = Data(string.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
