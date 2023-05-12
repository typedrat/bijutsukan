import SwiftUI
import Boutique
import NukeUI

struct BooruListView<Children: View>: View {
    @StateObject var boorusController: BoorusController = BoorusController()
    @ViewBuilder var destinationView: (_ booru: Booru) -> Children
    @State private var booruFavicons: [UUID: URL] = [:]
    
    @State private var showConfirmationDialog = false
    @State private var confirmationDialogForBooru: Booru?
    
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
                    }
                        .frame(width: maxRowHeight * 0.8, height: maxRowHeight * 0.8)
                        .task {
                            booruFavicons[booru.id] = await booru.getFavicon()
                        }
                    
                    NavigationLink(booru.name) {
                        destinationView(booru)
                    }
                }
                .swipeActions(allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        confirmDeletion(for: booru)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    
                    Button {
                        openEditor(for: booru)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                .contextMenu {
                    Button("Edit Server") {
                        openEditor(for: booru)
                    }

                    Button("Delete Server", role: .destructive) {
                        confirmDeletion(for: booru)
                    }
                }
            }
        }
        .navigationTitle("Servers")
#if !os(macOS)
        .toolbar {
            Button(action: openEditor) {
                Image(systemName: "plus")
            }
        }
#endif
        .sheet(isPresented: $showEditor, onDismiss: editorDismissed) {
            BooruEditorView(booru: $editingBooru, shouldSaveBooru: $shouldSaveBooru)
        }
        .confirmationDialog("Are you sure?",
                            isPresented: $showConfirmationDialog,
                            presenting: confirmationDialogForBooru) { booru in
            Button("Delete", role: .destructive) {
                Task {
                    try await boorusController.removeBooru(booru: booru)
                }
            }
        } message: { booru in
            Text("The configured settings for \(booru.name) and all associated favorites will be lost!")
                .foregroundColor(Color.secondary)
        }
        
#if os(macOS)
        VStack {
            Spacer()
            HStack {
                Button(action: openEditor) {
                    Label("Add Server", systemImage: "plus.circle")
                }
                    .padding()
                    .buttonStyle(.borderless)
                Spacer()
            }
        }
#endif
    }
    
    private func openEditor(for booru: Booru) {
        editingBooru = booru
        showEditor = true
    }
    
    private func openEditor() {
        openEditor(for: Booru())
    }
    
    private func editorDismissed() {
        Task {
            if shouldSaveBooru {
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
    
    private func confirmDeletion(for booru: Booru) {
        showConfirmationDialog = true
        confirmationDialogForBooru = booru
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
            )) { booru in
                Text(booru.name)
            }
        }
    }
}
