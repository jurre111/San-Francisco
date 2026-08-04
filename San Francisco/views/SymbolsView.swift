//
//  SymbolsView.swift
//  San Francisco
//
//  Created by jurre111 on 04.08.26.
//

import SwiftUI

struct SymbolsView: View {
    @State private var searchText: String = ""
    @State private var showSheet: Bool = false
    @State private var selectedSymbol: String = ""
    var category: sfmgr.Category

    var body: some View {
        List {
            ForEach(filteredSymbols(category.symbols), id: \.self) { symbol in
                Button {
                    selectedSymbol = symbol
                    showSheet = true
                } label: {
                    HStack {
                        Image(systemName: symbol)
                            .frame(width: 20, alignment: .center)
                        Text(symbol)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .fontWeight(.semibold)
                            .foregroundStyle(.tertiary)
                            .imageScale(.small)
                    }
                }
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = symbol
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    Button {
                        selectedSymbol = symbol
                        showSheet = true
                    } label: {
                        Label("Information", systemImage: "info.circle")
                    }
                }
            }
        }
        .navigationTitle(category.displayName)
        .searchable(text: $searchText, prompt: "Search Symbols")
        .sheet(isPresented: $showSheet) {
            SymbolView(symbol: selectedSymbol)
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