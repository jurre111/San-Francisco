//
//  SymbolsView.swift
//  San Francisco
//
//  Created by jurre111 on 04.08.26.
//

import SwiftUI

struct InfoSheet: Identifiable {
    var id: String { name }
    let name: String
    let info: sfmgr.Symbol
}

struct SymbolsView: View {
    @ObservedObject var mgr: sfmgr = sfmgr.shared
    @State private var searchText: String = ""
    @State private var infoSheet: InfoSheet? = nil
    let category: sfmgr.Category
    @State private var allSymbols: [String] = []
    @State private var shownSymbols: [String] = []
    @State private var loaded: Bool = false

    var body: some View {
        Group {
            if loaded {
                List(shownSymbols, id: \.self) { symbol in
                    if let symbolInfo = mgr.symbols[symbol] {
                        SymbolListView(symbol: symbol, info: symbolInfo, infoSheet: $infoSheet)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(category.displayName)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Symbols")
        .onChange(of: searchText) { newValue in
            if newValue.isEmpty {
                shownSymbols = allSymbols
            }
        }
        .onSubmit(of: .search) {
            await filterSymbols()
        }
        .sheet(item: $infoSheet) { symbol in
            SymbolInfoView(symbol: symbol.name, info: symbol.info)
        }
        .task {
            await load()
            loaded = true
        }
    }

    func load() async {
        let sortedSymbols = category.symbols.sorted()
        allSymbols = sortedSymbols
        shownSymbols = sortedSymbols
    }

    func filterSymbols() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.global(qos: .userInitiated).async {
            let filtered = allSymbols.filter { $0.localizedCaseInsensitiveContains(query) }

            DispatchQueue.main.async {
                shownSymbols = filtered
            }
        }
    }
}