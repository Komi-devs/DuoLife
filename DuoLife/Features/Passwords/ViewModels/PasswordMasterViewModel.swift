import SwiftUI

class PasswordMasterViewModel: ObservableObject {
    @Published var masterPassword = ""
    @Published var isAuthenticated = false
    @Published var showError = false
    @Published var isFirstTime = false
    
    init(masterManager: MasterPasswordManager) {
        self.isFirstTime = !masterManager.hasMasterPassword()
    }

    func submitPassword(masterManager: MasterPasswordManager) {
        if isFirstTime {
            try? masterManager.setMasterPassword(masterPassword)
            isAuthenticated = true
            masterManager.isAuthenticated = true
        } else {
            if masterManager.authenticate(masterPassword) {
                isAuthenticated = true
                masterManager.isAuthenticated = true
            } else {
                showError = true
            }
        }
    }
    
    func refreshFirstTime(masterManager: MasterPasswordManager) {
        masterPassword = ""
        showError = false
        isAuthenticated = false
        isFirstTime = !masterManager.hasMasterPassword()
    }
}
