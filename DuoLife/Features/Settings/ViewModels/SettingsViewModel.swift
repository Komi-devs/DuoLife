import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var resetToken = ""         // for admin/confirm input
    @Published var message: String?

    private let adminPassword = "admin"    // <-- keep secret / move to secure storage

    func updateMasterPassword(masterManager: MasterPasswordManager) {
        guard !oldPassword.isEmpty, !newPassword.isEmpty else {
            message = "All fields are required."
            return
        }
        guard newPassword == confirmPassword else {
            message = "New passwords do not match."
            return
        }
        do {
            let updated = try masterManager.updateMasterPassword(
                oldPassword: oldPassword,
                newPassword: newPassword
            )
            message = updated ? "Master password updated." : "Old password incorrect."
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    /// Reset logic:
    ///  - "admin" keeps encrypted data
    ///  - "confirm" wipes all secure data
    func resetMasterPassword(masterManager: MasterPasswordManager, passwordVM: PasswordMasterViewModel) {
        print(resetToken)
        let token = resetToken.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        switch token {
        case adminPassword:
            // only delete the stored master hash; encrypted passwords remain
            masterManager.removeMasterPasswordOnly()
            masterManager.isAuthenticated = false
            message = "Master password cleared (data kept)."
        case "confirm":
            // remove master hash and all user data (call your Firebase deletion if needed)
            masterManager.removeAllData()
            masterManager.isAuthenticated = false 
            message = "Master password and all encrypted data removed."
        default:
            message = "Invalid reset token."
        }
        resetToken = ""
        passwordVM.refreshFirstTime(masterManager: masterManager)
    }
}
