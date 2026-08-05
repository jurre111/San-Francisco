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
    @State private var query: String = ""
    @State private var searchText: String = ""
    @State private var symbolSheet: SymbolSheet? = nil
    var category: sfmgr.Category

    var body: some View {
        List {
            ForEach(filteredSymbols(category.symbols), id: \.self) { symbol in
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
                            mgr.favorites += symbol + ";"
                            mgr.symbols[symbol]!.favorite = true
                        } label: {
                            Label(symbolInfo.favorite ? "Remove from Favorites" : "Add to Favorites", systemImage: symbolInfo.favorite ? "star.slash" : "star")
                        }
                    }
                }
            }
        }
        .navigationTitle(category.displayName)
        .searchable(text: $searchText, prompt: "Search Symbols")
        .onSubmit(of: .search) {
            query = searchText
        }
        .sheet(item: $symbolSheet) { symbol in
            SymbolInfoView(symbol: symbol.name, info: symbol.info)
        }
    }

    private func filteredSymbols(_ symbolList: [String]) -> [String] {
        if query.isEmpty {
            return symbolList.sorted()
        } else {
            return symbolList.sorted().filter { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}