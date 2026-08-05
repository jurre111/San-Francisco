//
//  FavoritesView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var mgr: sfmgr = sfmgr.shared
    @State private var searchText: String = ""
    @State private var symbolSheet: (name: String, info: sfmgr.SymbolInfo)? = nil
    var category: sfmgr.Category

    var body: some View {
        if mgr.favorites == "" {
            Text("No favorites yet")
        } else {
            List {
                ForEach(filteredSymbols(favorites.components(separatedBy: ";").dropLast()), id: \.self) { symbol in
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
                                symbolSheet = (name: symbol, info: symbolInfo)
                            } label: {
                                Label("Info", systemImage: "info.circle")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                mgr.favorites = mgr.favorites.replacingOccurrences(of: symbol + ";", with: "")
                                mgr.symbols[symbol]?.favorite = false
                            } label: {
                                Label("Remove", systemImage: "star.slash")
                            }
                        }
                    }
                }
            }
            .navigationTitle(category.displayName)
            .searchable(text: $searchText, prompt: "Search Favorites")
            .sheet(item: $symbolSheet) { symbol in
                SymbolInfoView(symbol: symbol.name, info: symbol.info)
            }
        }
    }

    private func filteredSymbols(_ symbolList: [String]) -> [String] {
        if searchText.isEmpty {
            return symbolList.sorted()
        } else {
            return symbolList.sorted().filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}