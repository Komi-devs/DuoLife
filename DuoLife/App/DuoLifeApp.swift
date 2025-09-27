import SwiftUI
import Firebase

@main
struct DuoLifeApp: App {
    @StateObject private var masterManager = MasterPasswordManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(masterManager) // inject globally
        }
    }
}


struct MainTabView: View {
    @EnvironmentObject var masterManager: MasterPasswordManager
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            // ---------- Accounts ----------
            AccountListView()
                .tabItem {
                    Label("Accounts", systemImage: "list.bullet")
                }
                .tag(0)

            // ---------- Passwords ----------
            Group {
                if masterManager.isAuthenticated {
                    PasswordCategoryListView()
                        .environmentObject(masterManager)
                } else {
                    PasswordMasterView(masterManager: masterManager)
                }
            }
            .tabItem {
                Label("Password", systemImage: masterManager.isAuthenticated ? "lock.open" : "lock.fill")
            }
            .tag(1)

            // ---------- Groceries ----------
            GroceriesMainView()     // 👈 new combined groceries section
                .tabItem {
                    Label("Groceries", systemImage: "cart")
                }
                .tag(2)
            
            // ---------- Restaurants ----------
            RestaurantListView()
                .tabItem {
                    Label("Restaurants", systemImage: "fork.knife")
                }
                .tag(3)

            // ---------- Settings ----------
            SettingsView()
                .environmentObject(masterManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}
