import SwiftUI
import Boutique
import NukeUI

struct BooruListView: View {
    @StateObject var boorusController: BoorusController = BoorusController()
    @State private var booruFavicons: [UUID: URL] = [:]
    
    @State private var showEditor: Bool = false
    @State private var shouldSaveBooru: Bool = false
    @State private var editingBooru: Booru = Booru()
    
    var body: some View {
        let environmentValues = EnvironmentValues()
        let maxRowHeight = environmentValues.defaultMinListRowHeight
        
        List {
            ForEach(boorusController.boorus) { booru in
                HStack {
                    LazyImage(url: booruFavicons[booru.id]) { state in
                        if let image = state.image {
                            image.resizable().aspectRatio(1.0, contentMode: .fit)
                        } else if state.error != nil && booruFavicons[booru.id] != nil {
                            Color.red
                        } else {
                            EmptyView()
                        }
                    }.frame(width: maxRowHeight * 0.8, height: maxRowHeight * 0.8)
                        .task {
                            booruFavicons[booru.id] = await booru.getFavicon()
                        }
                    
                    NavigationLink(booru.name) {
                        Text("foo")
                    }
                }
                .swipeActions(allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task {
                            try await boorusController.removeBooru(booru: booru)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    
                    Button {
                        editingBooru = booru
                        showEditor = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("Servers")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editingBooru = Booru()
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
        }
        .sheet(isPresented: $showEditor, onDismiss: editorDismissed) {
            BooruEditorView(booru: $editingBooru, shouldSaveBooru: $shouldSaveBooru)
        }
    }
    
    private func editorDismissed() {
        Task {
            if shouldSaveBooru {
                print("new booru:", editingBooru as Any)
                
                do {
                    var booruToSave = editingBooru
                    await booruToSave.autodetectType()
                    try await boorusController.saveBooru(booru: booruToSave)
                } catch {
                    print("unhandled error saving booru:", error as Any)
                }
            }
            
            editingBooru = Booru()
        }
    }
}

struct BooruListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BooruListView(boorusController: BoorusController(
                store: .previewStore(items: [
                    Booru(id: UUID(uuidString: "bc4a3b91-ab61-418e-a387-d16abc13a182")!,
                          name: "e621",
                          baseUrl: URL(string: "https://e621.net")!,
                          booruType: .autodetect,
                          onlySafeContent: true,
                          username: "",
                          password: ""
                         ),
                    Booru(id: UUID(uuidString: "a8a738a7-d5b6-4afc-974e-299b90a411a4")!,
                          name: "Danbooru",
                          baseUrl: URL(string: "https://danbooru.donmai.us")!,
                          booruType: .autodetect,
                          onlySafeContent: true,
                          username: "",
                          password: ""
                         )
                ], cacheIdentifier: \.id.uuidString)
            ))
        }
    }
}
