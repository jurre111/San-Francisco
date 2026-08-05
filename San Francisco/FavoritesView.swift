//
//  FavoritesView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var mgr: sfmgr = sfmgr.shared
    @State private var query: String = ""
    @State private var searchText: String = ""
    @State private var symbolSheet: InfoSheet? = nil

    var body: some View {
        NavigationStack {
            List {
                if mgr.favorites.isEmpty {
                    Text("No favorites yet")
                } else {
                    ForEach(filteredSymbols(mgr.favorites.components(separatedBy: ";").dropLast()), id: \.self) { symbol in
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
                                    symbolSheet = InfoSheet(name: symbol, info: symbolInfo)
                                } label: {
                                    Label("Info", systemImage: "info.circle")
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    mgr.favorites = mgr.favorites.replacingOccurrences(of: symbol + ";", with: "")
                                    mgr.symbols[symbol]?.favorite = false
                                } label: {
                                    Text("Remove")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Favorites")
            .onSubmit(of: .search) {
                query = searchText
            }
            .sheet(item: $symbolSheet) { symbol in
                SymbolInfoView(symbol: symbol.name, info: symbol.info)
            }
        }
    }

    private func filteredSymbols(_ symbolList: [String]) -> [String] {
        if query.isEmpty || (!query.isEmpty && searchText.isEmpty) {
            return symbolList.sorted()
        } else {
            return symbolList.sorted().filter { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}