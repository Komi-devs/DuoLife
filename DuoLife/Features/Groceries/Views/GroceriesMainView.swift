import SwiftUI

struct GroceriesMainView: View {
    @StateObject private var shoppingVM = GroceryListViewModel()
    @StateObject private var ownedVM = OwnedGroceriesViewModel()

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack {
                // Optional top segmented control
                Picker("View", selection: $selectedTab) {
                    Text("Shopping List").tag(0)
                    Text("Owned Groceries").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Swipeable pages
                TabView(selection: $selectedTab) {
                    GroceryListView()
                        .environmentObject(shoppingVM)
                        .tag(0)

                    OwnedGroceriesView()
                        .environmentObject(ownedVM)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Groceries")
        }
    }
}
