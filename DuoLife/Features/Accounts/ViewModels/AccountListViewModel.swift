import Foundation
import Combine

class AccountListViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var showAddSheet: Bool = false
    
    private let firestore = FirestoreService()
    
    func loadAccounts() {
        firestore.fetchAccounts { accounts in
            DispatchQueue.main.async {
                self.accounts = accounts
            }
        }
    }
    
    func addAccount(name: String) {
        firestore.addAccount(name: name) { success in
            if success {
                self.loadAccounts()
            }
        }
    }
}

