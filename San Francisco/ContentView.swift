import SwiftUI


struct Symbol: Codable {
    var categories: [String]
    var availability: String
}

struct Category: Codable {
    var displayName: String
    var displayIcon: String
    var symbols: [String]
}

struct ContentView: View {
    @State private var symbols: [String: Symbol] = [:]
    @State private var categories: [String: Category] = [:]
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories.keys.sorted(), id: \.self) { category in
                    if let catInfo = categories[category] {
                        NavigationLink(catInfo.displayName) {
                            List {
                                ForEach(catInfo.symbols, id: \.self) { symbol in
                                    HStack(spacing: 12) {
                                        Image(systemName: symbol)
                                            .frame(width: 20, alignment: .center)
                                        Text(symbol)
                                    }
                                }
                            }
                            .navigationTitle(catInfo.displayName)
                        }
                    }
                }
            }
            .navigationTitle("San Francisco")
        }
        .onAppear {
            let result = load()
            if !result.ok {
                Alertinator.shared.alert(title: "Error", body: result.message)
            }
        }
    }

    func load() -> (ok: Bool, message: String) {
        guard let url = Bundle.main.url(forResource: "symbols", withExtension: "plist") else {
            return (ok: false, message: "symbols.plist is missing??")
        }
        do {
            let data = try Data(contentsOf: url)
            symbols = try PropertyListDecoder().decode([String: Symbol].self, from: data)
        } catch {
            return (ok: false, message: "Failed to load symbols.plist: \(error)")
        }
        categories = loadCategories(symbols)
        return (ok: true, message: "")
    }
}

func loadCategories(_ symbols: [String: Symbol]) -> [String: Category] {
    var categories: [String: Category] = [:]
    for (symbol, info) in symbols {
        for category in info.categories {
            if categories[category] == nil {
                categories[category] = Category(displayName: category, displayIcon: "", symbols: [])
            }
            categories[category]!.symbols.append(symbol)
        }
    }
    for (category, info) in categories {
        categories[category]!.symbols.sort()
    }
    return categories
}

#Preview {
    ContentView()
}