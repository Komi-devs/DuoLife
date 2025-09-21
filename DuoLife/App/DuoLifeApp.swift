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
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AccountListView()
        }
    }
}
