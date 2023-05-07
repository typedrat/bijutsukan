import Foundation
import Boutique

final class BoorusController: ObservableObject {
    @Stored var boorus: [Booru]
    
    init() {
        self._boorus = Stored(in:
            Store<Booru>(storage:
                SQLiteStorageEngine.default(appendingPath: "boorus")
            )
        )
    }
    
    init(store: Store<Booru>) {
        self._boorus = Stored(in: store)
    }
    
    func saveBooru(booru: Booru) async throws {
        try await self.$boorus.insert(booru)
    }
    
    func removeBooru(booru: Booru) async throws {
        try await self.$boorus.remove(booru)
    }
    
    func getById(_ uuid: UUID) async -> Booru? {
        return await self.boorus.first(where: { $0.id == uuid })
    }
}
