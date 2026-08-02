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
                                    if let symbolInfo = symbols[symbol] {
                                        HStack(spacing: 10) {
                                            Image(systemName: symbol)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                            Text(symbol)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("San Francisco")
        .onAppear {
            guard let url = Bundle.main.url(forResource: "symbols", withExtension: "plist") else {
                return
            }
            let data = try Data(contentsOf: url)
            symbols = try PropertyListDecoder().decode([String: Symbol].self, from: data)

            categories = loadCategories(symbols)
        }
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
    return categories
}

#Preview {
    ContentView()
}