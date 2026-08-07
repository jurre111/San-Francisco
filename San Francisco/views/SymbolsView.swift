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

    let category: String

    var body: some View {
        Group {
            if loaded {
                List {
                    ForEach(shownSymbols, id: \.self) { symbol in
                        SymbolListView(symbol: symbol, infoSheet: $infoSheet)
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
            Task {
                await search()
            }
        }
        .sheet(item: $infoSheet) { symbol in
            SymbolInfoView(symbol: symbol)
        }
        .task {
            await load()
            loaded = true
        }
    }

    func load() async {
        let relevantSymbols = sfmgr.shared.symbols.filter { $0.categories.contains(category) }
        allSymbols = relevantSymbols
        shownSymbols = relevantSymbols
    }

    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.global(qos: .userInitiated).async {
            let filtered = allSymbols.filter { $0.name.localizedCaseInsensitiveContains(query) }

            DispatchQueue.main.async {
                shownSymbols = filtered
            }
        }
    }
}