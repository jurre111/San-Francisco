//
//  sfmgr.swift
//  San Francisco
//
//  Created by jurre111 on 04.08.26.
//

import SwiftUI
import Foundation

@MainActor
final class sfmgr: ObservableObject {
    @Published var symbols: [Symbol] = []
    @Published var categories: [Category] = []
    @Published var favorites: [String] = []

    @AppStorage("favoritesString") var favoritesString: String = ";"

    static let shared = sfmgr()

    struct Symbol: Codable, Hashable, Identifiable {
        var id: String { name }
        var name: String
        var categories: [String]
        var availability: Double
    }

    struct Category: Codable, Hashable {
        var name: String
        var displayName: String
        var icon: String
    }

    func load() -> (ok: Bool, message: String) {
        let symbolResult = loadSymbols()
        guard symbolResult.ok else {
            return (false, symbolResult.message)
        }
        symbols = symbolResult.symbols

        let categoriesResult = loadCategories()
        guard categoriesResult.ok else {
            return (false, categoriesResult.message)
        }
        categories = categoriesResult.categories


        let systemVersion = doubleSystemVersion()
        symbols = symbols.filter { symbol in
            return symbol.availability <= systemVersion && UIImage(systemName: symbol.name) != nil
        }

        let aliasesResult = loadAliases()
        guard aliasesResult.ok else {
            return (false, aliasesResult.message)
        }
        for category in categories.indices {
            let icon = categories[category].icon
            guard UIImage(systemName: icon) != nil else {
                categories[category].icon = aliasesResult.aliases[icon] ?? "questionmark.square"
            }
        }

        favorites = favoritesString.split(separator: ";").map(String.init)

        return (ok: true, message: "")
    }


    func toggleFavorite(symbol: String) {
        if !favoritesString.contains(";\(symbol);") {
            favoritesString += symbol + ";"
            favorites.append(symbol)
        } else {
            favoritesString = favoritesString.replacingOccurrences(of: ";\(symbol);", with: ";")
            favorites.removeAll { $0 == symbol }
        } 
    }

    private func loadSymbols() -> (ok: Bool, symbols: [Symbol], message: String) {
        guard let url = Bundle.main.url(forResource: "symbols", withExtension: "plist") else {
            return (false, [], message: "symbols.plist is missing??")
        }
        do {
            let data = try Data(contentsOf: url)
            let symbols = try PropertyListDecoder().decode([Symbol].self, from: data)
            return (true, symbols, message: "")
        } catch {
            return (false, [], message: "Failed to load symbols.plist: \(error)")
        }
    }

    private func loadCategories() -> (ok: Bool, categories: [Category], message: String) {
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "plist") else {
            return (ok: false, categories: [], message: "categories.plist is missing??")
        }
        do {
            let data = try Data(contentsOf: url)
            let categories = try PropertyListDecoder().decode([Category].self, from: data)
            return (ok: true, categories: categories, message: "")
        } catch {
            return (ok: false, categories: [], message: "Failed to load categories.plist: \(error)")
        }
    }

    private func loadAliases() -> (ok: Bool, aliases: [String: String], message: String) {
        guard let url = Bundle.main.url(forResource: "name_aliases", withExtension: "plist") else {
            return (ok: false, aliases: [:], message: "name_aliases.plist is missing??")
        }
        do {
            let data = try Data(contentsOf: url)
            let aliases = try PropertyListDecoder().decode([String: String].self, from: data)
            return (ok: true, aliases: aliases, message: "")
        } catch {
            return (ok: false, aliases: [:], message: "Failed to load name_aliases.plist: \(error)")
        }
    }
}