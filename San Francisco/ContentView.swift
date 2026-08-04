import SwiftUI
import Foundation

struct Symbol: Codable {
    var categories: [String]
    var availability: String
}

struct Category: Codable, Hashable {
    var key: String
    var icon: String
    var displayName: String
    var symbols: [String]
}


struct ContentView: View {
    @State private var symbols: [String: Symbol] = [:]
    @State private var categories: [Category] = []
    @State private var showSettings: Bool = false
    @State private var searchText: String = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { category in
                    NavigationLink {
                        List {
                            ForEach(filteredSymbols(category.symbols), id: \.self) { symbol in
                                HStack(spacing: 12) {
                                    Image(systemName: symbol)
                                        .frame(width: 20, alignment: .center)
                                    Text(symbol)
                                }
                            }
                        }
                        .navigationTitle(category.displayName)
                        .searchable(text: $searchText, prompt: "Search Symbols")
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .frame(width: 20, alignment: .center)
                            Text(category.key)
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

    func filteredSymbols(_ symbolList: [String]) -> [String] {
        if searchText.isEmpty {
            return symbolList.sorted()
        } else {
            return symbolList.sorted().filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func load() -> (ok: Bool, message: String) {
        let symbolResult = loadSymbols()
        if !symbolResult.ok {
            return (false, symbolResult.message)
        }
        symbols = symbolResult.dict

        let yearToReleaseResult = loadYearToRelease()
        if !yearToReleaseResult.ok {
            return (false, yearToReleaseResult.message)
        }
        let release = yearToReleaseResult.dict
        let systemVersion = doubleSystemVersion()
        for symbol in symbols.keys {
            if systemVersion < release[symbols[symbol]!.availability]! {
                symbols[symbol] = nil
            }
        }

        let categoriesResult = loadCategories()
        if !categoriesResult.ok {
            return (false, categoriesResult.message)
        }
        categories = categoriesResult.array

        let checkResult = checkCategoriesIconAvailability(categories: categories, symbols: symbols)
        if !checkResult.ok {
            return (false, checkResult.message)
        }
        categories = checkResult.array
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

func loadYearToRelease() -> (ok: Bool, dict: [String: Double], message: String, ) {
    guard let url = Bundle.main.url(forResource: "year_to_release", withExtension: "plist") else {
        return (ok: false, dict: [:], message: "year_to_release.plist is missing??")
    }
    do {
        let data = try Data(contentsOf: url)
        let yearsDict = try PropertyListDecoder().decode([String: [String: Double]].self, from: data)
        var yearToRelease: [String:Double] = [:]
        for (key, value) in yearsDict {
            yearToRelease[key] = value["iOS"] ?? 0.0
        }
        return (ok: true, dict: yearToRelease, message: "")
    } catch {
        return (ok: false, dict: [:], message: "Failed to load year_to_release.plist: \(error)")
    }
}

func loadCategories() -> (ok: Bool, array: [Category], message: String) {
    guard let url = Bundle.main.url(forResource: "categories", withExtension: "plist") else {
        return (ok: false, array: [], message: "categories.plist is missing??")
    }
    do {
        let data = try Data(contentsOf: url)
        let categories = try PropertyListDecoder().decode([Category].self, from: data)
        return (ok: true, array: categories, message: "")
    } catch {
        return (ok: false, array: [], message: "Failed to load categories.plist: \(error)")
    }
}

func checkCategoriesIconAvailability(categories: [Category], symbols: [String: Symbol])  -> (ok: Bool, array: [Category], message: String) {
    guard let url = Bundle.main.url(forResource: "name_aliases", withExtension: "plist") else {
        return (ok: false, array: [], message: "name_aliases.plist is missing??")
    }
    do { 
        let data = try Data(contentsOf: url)
        let aliases = try PropertyListDecoder().decode([String: String].self, from: data)
        
        var categoriesCopy = categories
        for index in categoriesCopy.indices {
            var category = categoriesCopy[index]
            category.symbols = category.symbols.filter { symbols[$0] != nil }
            // this means it got removed because the iOS version is too low
            if symbols[category.icon] == nil {
                let alias = aliases[category.icon] ?? "questionmark.square"
                category.icon = symbols[alias] != nil ? alias : "questionmark.square"
            }
            categoriesCopy[index] = category
        }
        return (ok: true, array: categoriesCopy, message: "")
    } catch {
        return (ok: false, array: [], message: "Failed to load name_aliases.plist: \(error)")
    }
}


#Preview {
    ContentView()
}