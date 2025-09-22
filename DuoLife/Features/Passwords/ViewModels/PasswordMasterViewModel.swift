import SwiftUI

final class PasswordMasterViewModel: ObservableObject {
    @Published var inputPassword: String = ""

    var masterManager: MasterPasswordManager

    init(masterManager: MasterPasswordManager) {
        self.masterManager = masterManager
    }

    var isFirstTime: Bool {
        !masterManager.hasMasterPassword()
    }

    var showError: Bool {
        // true when user has tried to log in and manager.isAuthenticated is still false
        !isFirstTime && !masterManager.isAuthenticated && !inputPassword.isEmpty
    }

    func submit() {
        if isFirstTime {
            do {
                try masterManager.setMasterPassword(inputPassword)
                _ = masterManager.authenticate(inputPassword)   // mark as authenticated & store in memory
            } catch {
                print("Error setting master password:", error)
            }
        } else {
            if !masterManager.authenticate(inputPassword) {
                // manager.isAuthenticated remains false → showError will be true
            }
        }
        inputPassword = ""
    }

    func resetForNewSession() {
        inputPassword = ""
        masterManager.signOut()
    }
    
    /// New method to refresh the first-time state
    func refreshFirstTime() {
        // Clear the input
        inputPassword = ""
        // Sign out to reset authentication state
        masterManager.signOut()
        // Trigger any @Published observers (if needed)
        objectWillChange.send()
    }
}
