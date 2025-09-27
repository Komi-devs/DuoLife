import SwiftUI

struct RestaurantListView: View {
    @StateObject private var viewModel = RestaurantListViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.restaurants) { restaurant in
                    NavigationLink(destination: NotesListView(restaurant: restaurant)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(restaurant.name).font(.headline)
                                if let nat = restaurant.nationality { Text(nat).font(.subheadline) }
                                if let city = restaurant.city { Text(city).font(.subheadline) }
                            }

                            Spacer()

                            // Count of notes
                            NotesCountView(restaurantId: restaurant.id ?? "")
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { idx in
                        viewModel.delete(viewModel.restaurants[idx])
                    }
                }
            }
            .navigationTitle("Restaurants")
            .toolbar {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddRestaurantView { newRestaurant in
                    viewModel.add(newRestaurant)   // ✅ call the service
                }
            }
            .onAppear { viewModel.loadRestaurants() }
        }
    }
}
