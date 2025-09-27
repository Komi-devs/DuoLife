import SwiftUI

struct GroceriesMainView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Shopping List") {
                    GroceryListView()
                        .environmentObject(GroceryListViewModel())
                }
                NavigationLink("Owned Groceries") {
                    OwnedGroceriesView()
                        .environmentObject(OwnedGroceriesViewModel())
                }
            }
            .navigationTitle("Groceries")
        }
    }
}
