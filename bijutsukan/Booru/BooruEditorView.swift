import SwiftUI

struct BooruEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var booru: Booru
    @Binding var shouldSaveBooru: Bool
    
    var body: some View {
        let urlBinding = Binding(
            get: { self.booru.baseUrl?.absoluteString ?? "" },
            set: { self.booru.baseUrl = URL(string: $0) }
        )
        
        NavigationStack {
            Form {
                Section("Server Information") {
                    TextField("Name", text: $booru.name)
                    
                    Picker("Server Type", selection: $booru.booruType) {
                        ForEach(BooruType.allCases) { type in
                            Text(type.displayName)
                        }
                    }

                    TextField("URL", text: urlBinding)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    Toggle(isOn: $booru.onlySafeContent) {
                        Text("Enable Rating Filter")
                    }
                }
                
                Section("Credentials") {
                    TextField("Username", text: $booru.username)
                        .textContentType(.username)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    SecureField("Password", text: $booru.password)
                        .textContentType(.password)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Add Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        shouldSaveBooru = false
                        dismiss()
                    }.foregroundColor(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        shouldSaveBooru = true
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BooruEditorView_Previews: PreviewProvider {
    static var previews: some View {
        var booru = Booru()
        
        BooruEditorView(
            booru: Binding(get: { booru }, set: { booru = $0 }),
            shouldSaveBooru: Binding.constant(false)
        )
    }
}
