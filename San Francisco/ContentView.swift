import SwiftUI
import Foundation

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
    @State private var showSettings: Bool = false
    @State private var searchText: String = ""
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("All") {
                    List {
                        ForEach(symbols.keys.sorted(), id: \.self) { symbol in
                            HStack(spacing: 12) {
                                Image(systemName: symbol)
                                    .symbolRenderingMode(.multicolor)
                                    .frame(width: 20, alignment: .center)
                                Text(symbol)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search for Symbols")
                }
                ForEach(categories.keys.sorted(), id: \.self) { category in
                    if let catInfo = categories[category] {
                        NavigationLink(catInfo.displayName) {
                            List {
                                ForEach(catInfo.symbols, id: \.self) { symbol in
                                    HStack(spacing: 12) {
                                        Image(systemName: symbol)
                                            .symbolRenderingMode(.multicolor)
                                            .frame(width: 20, alignment: .center)
                                        Text(symbol)
                                    }
                                }
                            }
                            .navigationTitle(catInfo.displayName)
                            .searchable(text: $searchText, prompt: "Search for Symbols")
                        }
                    }
                }
            }
            .navigationTitle("San Francisco")
            .toolbar {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .onAppear {
            let result = load()
            if !result.ok {
                Alertinator.shared.alert(title: "Error", body: result.message)
            }
        }
    }

    func load() -> (ok: Bool, message: String) {
        var result = loadSymbols()
        if !result.ok {
            return result
        }
        symbols = result.dict

        result = loadYearToRelease()
        if !result.ok {
            return result
        }
        let yearToRelease = result.dict
        let systemVersion = doubleSystemVersion()
        for symbol in symbols.keys {
            if systemVersion < yearToRelease[symbols[symbol]!.availability] {
                symbols[symbol] = nil
            }
        }

        categories = loadCategories(symbols)
        return (ok: true, message: "")
    }
}

func loadSymbols() -> (ok: Bool, dict: [String: Symbol], message: String) {
    guard let url = Bundle.main.url(forResource: "symbols", withExtension: "plist") else {
        return (ok: false, dict: [:], message: "symbols.plist is missing??")
    }
    do {
        let data = try Data(contentsOf: url)
        let symbols = try PropertyListDecoder().decode([String: Symbol].self, from: data)
        return (ok: true, dict: symbols, message: "")
    } catch {
        return (ok: false, dict: [:], message: "Failed to load symbols.plist: \(error)")
    }
}

func loadYearToRelease() -> (ok: Bool, dict: [String:[String:String]], message: String, ) {
    guard let url = Bundle.main.url(forResource: "year_to_release", withExtension: "plist") else {
        return (ok: false, dict: [:], message: "symbols.plist is missing??")
    }
    do {
        let data = try Data(contentsOf: url)
        let dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        var yearToRelease: [String:String] = [:]
        for (key, value) in dict {
            yearToRelease[key] = Double(value["iOS"]!) ?? 0.0
        }
        return (ok: true, dict: yearToRelease, message: "")
    } catch {
        return (ok: false, dict: [:], message: "Failed to load symbols.plist: \(error)")
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