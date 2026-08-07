//
//  SymbolListView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolListView: View {
    // @State private var isFavorite: Bool = false
    let symbol: sfmgr.Symbol
    @Binding var infoSheet: sfmgr.Symbol?

    var body: some View {
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
            // Button {
            //     sfmgr.shared.toggleFavorite(symbol: symbol.name)
            //     isFavorite.toggle()
            // } label: {
            //     Label(isFavorite ? "Remove from Favorites" : "Add to Favorites", systemImage: isFavorite ? "star.slash" : "star")
            // }
        }
        // .onAppear {
        //     isFavorite = sfmgr.shared.favorites.contains(symbol.name)
        // }
    }
}