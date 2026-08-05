//
//  SymbolListView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolListView: View {
    var symbol: String
    var info: sfmgr.Symbol
    @Binding var infoSheet: InfoSheet?
    @State private var isFavorite: Bool = false

    var body: some View {
        NavigationLink {
            SymbolCustomizeView(symbol: symbol, info: info)
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
                infoSheet = InfoSheet(name: symbol, info: info)
            } label: {
                Label("Info", systemImage: "info.circle")
            }
            Button {
                sfmgr.shared.toggleFavorite(symbol: symbol)
                isFavorite.toggle()
            } label: {
                Label(isFavorite ? "Remove from Favorites" : "Add to Favorites", systemImage: isFavorite ? "star.slash" : "star")
            }
        }
        .onAppear {
            isFavorite = info.favorite
        }
    }
}