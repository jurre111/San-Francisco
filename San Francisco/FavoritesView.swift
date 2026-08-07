//
//  FavoritesView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var mgr: sfmgr
    @State private var searchText: String = ""
    @State private var infoSheet: sfmgr.Symbol? = nil
    @State private var allSymbols: [sfmgr.Symbol] = []
    @State private var shownSymbols: [sfmgr.Symbol] = []
    @State private var loaded: Bool = false

    var body: some View {
        Group {
            if loaded {
                List {
                    ForEach(shownSymbols, id: \.self) { symbol in
                        NavigationLink {
                            SymbolCustomizeView(symbol: symbol)
                        } label: {
                            HStack {
                                Image(systemName: symbol.name)
                                    .frame(width: 20, alignment: .center)
                                Text(symbol.name)
                            }
                        }
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = symbol.name
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            Button {
                                infoSheet = symbol
                            } label: {
                                Label("Info", systemImage: "info.circle")
                            }
                            Button {
                                sfmgr.shared.toggleFavorite(symbol: symbol)
                                allSymbols.removeAll { $0.name == symbol.name }
                                shownSymbols.removeAll { $0.name == symbol.name }
                            } label: {
                                Label("Remove from Favorites", systemImage: "star.slash")
                            }
                        }
                    }
                }
                .refreshable {
                    await load()
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Favorites")
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
        let relevantSymbols = sfmgr.shared.symbols.filter { mgr.favorites.contains($0.name) }
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