//
//  SymbolCustomizeView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolCustomizeView: View {
    @ObservedObject var mgr: sfmgr = sfmgr.shared
    @State private var symbolSheet: String? = nil
    @State private var renderingMode: String = "default"
    var symbol: String
    var info: sfmgr.Symbol

    var body: some View {
        NavigationStack {
            List{
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1.0, contentMode: .fit)
                    Image(systemName: symbol)
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
                        if info.categories.contains("multicolor") {
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
            .sheet(item: $symbolSheet) { selectedSymbol in
                SymbolInfoView(symbol: selectedSymbol, info: info)
            }
            .toolbar {
                Button {
                    mgr.favorites += symbol + ";"
                    mgr.symbols[symbol]!.favorite = true
                } label: {
                    Image(systemName: info.favorite ? "star.fill" : "star")
                }
                Button {
                    symbolSheet = symbol
                } label: {
                    Image(systemName: "info.circle")
                }
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