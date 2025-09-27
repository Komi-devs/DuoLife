import Foundation

class SettingsViewModel: ObservableObject {
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var resetToken = ""     // "admin" or "confirm"
    @Published var message: String?

    private let adminPassword = "admin"
    private let firestore = PasswordsService()

    // Change the master password
    func updateMasterPassword(using manager: MasterPasswordManager) {
        guard !oldPassword.isEmpty, !newPassword.isEmpty else {
            message = "All fields are required."
            return
        }
        guard newPassword == confirmPassword else {
            message = "New passwords do not match."
            return
        }
        do {
            let updated = try manager.updateMasterPassword(
                oldPassword: oldPassword,
                newPassword: newPassword
            )
            message = updated ? "Master password updated." : "Old password incorrect."
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
    }

    // Reset logic: "admin" keeps encrypted data, "confirm" wipes everything
    func resetMasterPassword(using manager: MasterPasswordManager) {
        let token = resetToken.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch token {
        case adminPassword:
            manager.removeMasterPasswordOnly()
            manager.signOut()
            message = "Master password cleared (data kept)."
        case "confirm":
            manager.resetMasterPasswordAndCleanDatabase(
                firestore: firestore
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        manager.signOut()
                        self?.message = "Master password and all encrypted data removed."
                    case .failure(let error):
                        self?.message = "Cleanup failed: \(error.localizedDescription)"
                    }
                }
            }
        default:
            message = "Invalid reset token."
        }

        // Reset the field for security
        resetToken = ""
    }
}
