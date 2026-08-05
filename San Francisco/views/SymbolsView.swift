//
//  SymbolsView.swift
//  San Francisco
//
//  Created by jurre111 on 04.08.26.
//

import SwiftUI

struct SymbolSheet: Identifiable {
    var id: String { name }
    let name: String
    let info: sfmgr.Symbol
}

struct SymbolsView: View {
    @ObservedObject var mgr: sfmgr = sfmgr.shared
    @State private var searchText: String = ""
    @State private var symbolSheet: SymbolSheet? = nil
    @State var category: sfmgr.Category
    @State private var shownSymbols: [String] = []
    @State private var loaded: Bool = false

    var body: some View {
        List {
            if loaded {
                ForEach(shownSymbols, id: \.self) { symbol in
                    if let symbolInfo = mgr.symbols[symbol] {
                        NavigationLink {
                            SymbolCustomizeView(symbol: symbol, info: symbolInfo)
                        } label: {
                            HStack {
                                Image(systemName: symbol)
                                    .frame(width: 20, alignment: .center)
                                Text(symbol)
                            }
                        }
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = symbol
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            Button {
                                symbolSheet = SymbolSheet(name: symbol, info: symbolInfo)
                            } label: {
                                Label("Info", systemImage: "info.circle")
                            }
                            Button {
                                if !symbolInfo.favorite {
                                    mgr.favorites += symbol + ";"
                                    mgr.symbols[symbol]?.favorite = true
                                } else {
                                    mgr.favorites = mgr.favorites.replacingOccurrences(of: symbol + ";", with: "")
                                    mgr.symbols[symbol]?.favorite = false
                                } 
                            } label: {
                                Label(symbolInfo.favorite ? "Remove from Favorites" : "Add to Favorites", systemImage: symbolInfo.favorite ? "star.slash" : "star")
                            }
                        }
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
                shownSymbols = category.symbols
            }
        }
        .onSubmit(of: .search) {
            shownSymbols = category.symbols.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
        .sheet(item: $symbolSheet) { symbol in
            SymbolInfoView(symbol: symbol.name, info: symbol.info)
        }
        .task {
            await load()
            loaded = true
        }
    }

    func load() async {
        category.symbols.sort()
        shownSymbols = category.symbols
    }
}