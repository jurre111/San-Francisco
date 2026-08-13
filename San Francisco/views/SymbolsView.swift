//
//  SymbolsView.swift
//  San Francisco
//
//  Created by jurre111 on 04.08.26.
//

import SwiftUI

struct SymbolsView: View {
    @State private var searchText: String = ""
    @State private var infoSheet: sfmgr.Symbol? = nil
    @State private var allSymbols: [sfmgr.Symbol] = []
    @State private var shownSymbols: [sfmgr.Symbol] = []
    @State private var loaded: Bool = false

    let category: sfmgr.Category

    var body: some View {
        List {
            ForEach(shownSymbols, id: \.self) { symbol in
                SymbolListView(symbol: symbol, infoSheet: $infoSheet)
            }
        }
        .navigationTitle(category.displayName)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Symbols")
        .onChange(of: searchText) { newValue in
            if newValue.isEmpty {
                shownSymbols = allSymbols
            } else {
                Task {
                    await search()
                }
            }
        }
        .sheet(item: $infoSheet) { symbol in
            SymbolInfoView(symbol: symbol)
        }
        .onAppear {
            load()
        }
    }

    func load() {
        let relevantSymbols = sfmgr.shared.symbols.filter { $0.categories.contains(category.name) }
        allSymbols = relevantSymbols
        shownSymbols = relevantSymbols
        loaded = true
    }

    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = allSymbols.filter { $0.name.localizedCaseInsensitiveContains(query) }
        shownSymbols = filtered
    }
}