import SwiftUI

struct NotesCountView: View {
    let restaurantId: String
    @State private var count = 0
    private let service = RestaurantsService()

    var body: some View {
        Text("\(count) notes").font(.caption).foregroundColor(.secondary)
            .onAppear { loadCount() }
    }

    func loadCount() {
        service.fetchNotes(for: restaurantId) { notes in
            DispatchQueue.main.async { count = notes.count }
        }
    }
}
