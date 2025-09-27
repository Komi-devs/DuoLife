import SwiftUI

struct NotesListView: View {
    let restaurant: Restaurant
    @StateObject private var viewModel: NotesViewModel
    @State private var author = ""
    @State private var content = ""

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        _viewModel = StateObject(wrappedValue: NotesViewModel(restaurantId: restaurant.id ?? ""))
    }

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.notes) { note in
                    VStack(alignment: .leading) {
                        Text(note.author).font(.headline)
                        Text(note.content)
                        Text(note.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Form {
                TextField("Author", text: $author)
                TextField("Note", text: $content)
                Button("Add Note") {
                    guard !author.isEmpty, !content.isEmpty else { return }
                    viewModel.addNote(author: author, content: content)
                    author = ""
                    content = ""
                }
            }
            .padding()
        }
        .navigationTitle(restaurant.name)
        .onAppear { viewModel.loadNotes() }
    }
}
