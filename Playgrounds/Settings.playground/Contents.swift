import Cocoa

// https://www.dogstar.mobi/api/t/users

struct Settings: Decodable {
    
}

struct SettingsLoader {
    
    var url: URL
    var urlSession = URLSession.shared
    var decoder = JSONDecoder()
    
    func load() async throws -> Settings {
        
        for _ in 0..<3 {
            do {
                return try await performLoading()
            } catch {
                continue
            }
        }
        
        return try await performLoading()
    }
    
    private func performLoading() async throws -> Settings {
        
        let (data, _) = try await urlSession.data(from: url)
        
        return try decoder.decode(Settings.self, from: data)
    }
}

if let url = URL(string: "https://www.dogstar.mobi/api/t/users") {
   
    let loader = SettingsLoader(url: url)
    try await loader.load()
}
