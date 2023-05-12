import Foundation
import FaviconFinder
import KeychainAccess

enum BooruType: Codable, Equatable, CaseIterable, Identifiable {
    case autodetect
    case e621
    
    var id: Self { self }

    var displayName: String {
        switch self {
        case .autodetect:
            return "Autodetect"
        case .e621:
            return "e621/e926"
        }
    }
}

struct Booru: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var baseUrl: URL?
    var booruType: BooruType
    var onlySafeContent: Bool
    
    var username: String
    var password: String
    
    init(id: UUID, name: String, baseUrl: URL? = nil, booruType: BooruType, onlySafeContent: Bool, username: String, password: String) {
        self.id = id
        self.name = name
        self.baseUrl = baseUrl
        self.booruType = booruType
        self.onlySafeContent = onlySafeContent
        self.username = username
        self.password = password
    }
    
    init() {
        self.id = UUID()
        self.name = "New Server"
        self.baseUrl = nil
        self.booruType = .autodetect
        self.onlySafeContent = true
        self.username = ""
        self.password = ""
    }
    
    mutating func autodetectType() async {
        if case .autodetect = booruType {
            // Currently only one type is supported!
            booruType = .e621
        }
    }
    
    func getFavicon() async -> URL? {
        if let baseUrl = self.baseUrl {
            let favicon = try? await FaviconFinder(url: baseUrl,
                                                  preferredType: .html,
                                                  preferences: [
                                                    .html: FaviconType.appleTouchIcon.rawValue
                                                  ],
                                                  downloadImage: false
            ).downloadFavicon()
            
            return favicon?.url
        } else {
            return nil
        }
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case baseUrl
        case booruType
        case onlySafeContent
        case username
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Booru.CodingKeys> = try decoder.container(keyedBy: Booru.CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: Booru.CodingKeys.id)
        self.name = try container.decode(String.self, forKey: Booru.CodingKeys.name)
        self.baseUrl = try container.decodeIfPresent(URL.self, forKey: Booru.CodingKeys.baseUrl)
        self.booruType = try container.decode(BooruType.self, forKey: Booru.CodingKeys.booruType)
        self.onlySafeContent = try container.decode(Bool.self, forKey: Booru.CodingKeys.onlySafeContent)
        self.username = try container.decode(String.self, forKey: Booru.CodingKeys.username)
        
        if let url = self.baseUrl {
            let keychain = Keychain(server: url, protocolType: .https)
                .accessibility(.afterFirstUnlock)
                .synchronizable(true)
            
            self.password = keychain[self.username] ?? ""
        } else {
            self.password = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<Booru.CodingKeys> = encoder.container(keyedBy: Booru.CodingKeys.self)
        
        try container.encode(self.id, forKey: Booru.CodingKeys.id)
        try container.encode(self.name, forKey: Booru.CodingKeys.name)
        try container.encodeIfPresent(self.baseUrl, forKey: Booru.CodingKeys.baseUrl)
        try container.encode(self.booruType, forKey: Booru.CodingKeys.booruType)
        try container.encode(self.onlySafeContent, forKey: Booru.CodingKeys.onlySafeContent)
        try container.encode(self.username, forKey: Booru.CodingKeys.username)
        
        if let url = self.baseUrl {
            let keychain = Keychain(server: url, protocolType: .https)
                .accessibility(.afterFirstUnlock)
                .synchronizable(true)
            
            keychain[self.username] = self.password
        }
    }
    
    func removeFromKeychain() {
        if let url = self.baseUrl {
            let keychain = Keychain(server: url, protocolType: .https)
                .accessibility(.afterFirstUnlock)
                .synchronizable(true)
            
            keychain[self.username] = self.password
        }
    }
}
