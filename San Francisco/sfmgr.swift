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
    @Published var symbols: [String: Symbol] = [:]
    @Published var categories: [Category] = []

    @AppStorage("favorites") var favorites: String = ";"

    static let shared = sfmgr()

    struct Symbol: Codable {
        var categories: [String]
        var availability: Double
        var favorite: Bool
    }

    struct Category: Codable, Hashable {
        var key: String
        var icon: String
        var displayName: String
        var symbols: [String]
    }

    func load() -> (ok: Bool, message: String) {
        let symbolResult = loadSymbols()
        if !symbolResult.ok {
            return (false, symbolResult.message)
        }
        symbols = symbolResult.dict

        let systemVersion = doubleSystemVersion()
        symbols = symbols.filter { _, info in
            return systemVersion >= info.availability
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


    func toggleFavorite(symbol: String) {
        if !favorites.contains(";\(symbol);") {
            favorites += symbol + ";"
            symbols[symbol]?.favorite = true
        } else {
            favorites = favorites.replacingOccurrences(of: ";\(symbol);", with: ";")
            symbols[symbol]?.favorite = false
        } 
    }

    private func loadSymbols() -> (ok: Bool, dict: [String: Symbol], message: String) {
        guard let url = Bundle.main.url(forResource: "symbols", withExtension: "plist") else {
            return (ok: false, dict: [:], message: "symbols.plist is missing??")
        }
        do {
            let data = try Data(contentsOf: url)
            var symbols = try PropertyListDecoder().decode([String: Symbol].self, from: data)
            for symbol in favorites.components(separatedBy: ";").dropLast() {
                symbols[symbol]?.favorite = true
            }
            return (ok: true, dict: symbols, message: "")
        } catch {
            return (ok: false, dict: [:], message: "Failed to load symbols.plist: \(error)")
        }
    }

    private func loadCategories() -> (ok: Bool, array: [Category], message: String) {
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

    private func checkCategoriesIconAvailability(categories: [Category], symbols: [String: Symbol])  -> (ok: Bool, array: [Category], message: String) {
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
            categoriesCopy = categoriesCopy.filter { !$0.symbols.isEmpty }
            return (ok: true, array: categoriesCopy, message: "")
        } catch {
            return (ok: false, array: [], message: "Failed to load name_aliases.plist: \(error)")
        }
    }
}