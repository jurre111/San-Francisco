//
//  SymbolCustomizeView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolCustomizeView: View {
    @ObservedObject var mgr: sfmgr = sfmgr.shared
    @State private var infoSheet: sfmgr.Symbol? = nil
    @State private var renderingMode: String = "default"
    @State private var isFavorite: Bool = false
    let symbol: sfmgr.Symbol

    var body: some View {
        NavigationStack {
            List{
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1.0, contentMode: .fit)
                    Image(systemName: symbol.name)
                        .symbolRenderingMode(getRenderingMode(from: renderingMode))
                        .font(.system(size: 220))
                        .foregroundColor(.blue)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                Section {
                    Picker("Style", selection: $renderingMode) {
                        Text("Default").tag("default")
                        if symbol.categories.contains("multicolor") {
                            Text("Multicolor").tag("multicolor")
                        }
                        Text("Hierarchical").tag("hierarchical")
                        Text("Palette").tag("palette")
                        Text("Monochrome").tag("monochrome")
                    }
                    NavigationLink("Color") {
                        List {
                            HStack {
                                Text("Color")
                                Spacer()
                                Text("Blue")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $infoSheet) { symbol in
                SymbolInfoView(symbol: symbol)
            }
            .toolbar {
                Button {
                    sfmgr.shared.toggleFavorite(symbol: symbol.name)
                    isFavorite.toggle()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                }
                Button {
                    infoSheet = symbol
                } label: {
                    Image(systemName: "info.circle")
                }
            }
            .onAppear {
                isFavorite = sfmgr.shared.favorites.contains(symbol.name)
            }
        }
    }

    func getRenderingMode(from string: String) -> SymbolRenderingMode? {
        switch string {
            case "default":
                return nil
            case "multicolor":
                return .multicolor
            case "hierarchical":
                return .hierarchical
            case "palette":
                return .palette
            case "monochrome":
                return .monochrome
            default:
                return nil
        }
    }
}