import Foundation
import Combine

final class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    private let service = RestaurantsService()
    let restaurantId: String

    init(restaurantId: String) {
        self.restaurantId = restaurantId
    }

    func loadNotes() {
        service.fetchNotes(for: restaurantId) { [weak self] notes in
            DispatchQueue.main.async {
                self?.notes = notes
            }
        }
    }

    func addNote(author: String, content: String) {
        let note = Note(
            restaurantId: restaurantId,
            author: author,
            content: content
        )
        service.addNote(note) { [weak self] success in
            if success { self?.loadNotes() }
        }
    }
}
