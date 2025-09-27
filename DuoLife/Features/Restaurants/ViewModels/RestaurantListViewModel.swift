import Foundation
import Combine

final class RestaurantListViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    private let service = RestaurantsService()

    func loadRestaurants() {
        service.fetchRestaurants { self.restaurants = $0 }
    }

    func add(_ restaurant: Restaurant) {
        service.addRestaurant(restaurant) { success in
            if success {
                // Reload list or append with generated ID
                self.loadRestaurants()
            }
        }
    }

    func delete(_ restaurant: Restaurant) {
        service.deleteRestaurant(restaurant) { success in
            if success {
                DispatchQueue.main.async {
                    self.restaurants.removeAll { $0.id == restaurant.id }
                }
            }
        }
    }
}
