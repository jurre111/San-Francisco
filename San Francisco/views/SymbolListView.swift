//
//  SymbolListView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolListView: View {
    var symbol: String
    @ObservedObject var mgr: sfmgr
    @Binding var infoSheet: InfoSheet?

    var body: some View {
        if let symbolBinding = Binding($mgr.symbols[symbol]) {
            NavigationLink {
                SymbolCustomizeView(symbol: symbol, info: symbolBinding.wrappedValue)
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
                    infoSheet = InfoSheet(name: symbol, info: symbolBinding.wrappedValue)
                } label: {
                    Label("Info", systemImage: "info.circle")
                }
                Button {
                    if !symbolBinding.wrappedValue.favorite {
                        mgr.favorites += symbol + ";"
                        symbolBinding.wrappedValue.favorite = true
                    } else {
                        mgr.favorites = mgr.favorites.replacingOccurrences(of: symbol + ";", with: "")
                        symbolBinding.wrappedValue.favorite = false
                    } 
                } label: {
                    Label(symbolBinding.wrappedValue.favorite ? "Remove from Favorites" : "Add to Favorites", systemImage: symbolBinding.wrappedValue.favorite ? "star.slash" : "star")
                }
            }
        }
    }
}