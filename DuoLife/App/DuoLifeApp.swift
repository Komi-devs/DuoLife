//
//  DuoLifeApp.swift
//  DuoLife
//
//  Created by Nathan Goldnadel on 14/09/2025.
//

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
                .environmentObject(masterManager)   // inject globally
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var masterManager: MasterPasswordManager
    @State private var selectedTab = 1   // 0 = Accounts, 1 = Password, 2 = Settings

    // Keep a single instance of PasswordMasterViewModel
    @StateObject private var passwordVM: PasswordMasterViewModel

    init() {
        // Initialize here with a placeholder; real masterManager will be injected in body
        _passwordVM = StateObject(wrappedValue: PasswordMasterViewModel(masterManager: MasterPasswordManager()))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            AccountListView()
                .tabItem {
                    Label("Accounts", systemImage: "list.bullet")
                }
                .tag(0)

            Group {
                if masterManager.isAuthenticated {
                    PasswordCategoryListView()
                } else {
                    PasswordMasterView(viewModel: passwordVM)
                        .environmentObject(masterManager)
                }
            }
            .tabItem {
                Label("Password", systemImage: masterManager.isAuthenticated ? "lock.open" : "lock.fill")
            }
            .tag(1)

            SettingsView(passwordVM: passwordVM)
                .environmentObject(masterManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .onAppear {
            // Update the PasswordMasterViewModel with the real masterManager injected via environment
            passwordVM.refreshFirstTime(masterManager: masterManager)
        }
    }
}
