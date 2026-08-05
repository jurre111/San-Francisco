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
    @State private var renderingMode: SymbolRenderingMode? = nil
    var symbol: String
    let symbolInfo = mgr.symbols[symbol]!

    var body: some View {
        NavigationStack {
            List{
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1.0, contentMode: .fit)
                    Image(systemName: symbol)
                        .symbolRenderingMode(renderingMode)
                        .font(.system(size: 220))
                        .foregroundColor(.blue)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                Section {
                    Picker("Style", selection: $renderingMode) {
                        Text("Automatic").tag(nil as SymbolRenderingMode?)
                        if symbolInfo.categories.contains("multicolor") {
                            Text("Multicolor").tag(.multicolor)
                        }
                        Text("Hierarchical").tag(.hierarchical)
                        Text("Palette").tag(.palette)

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
                SymbolInfoView(symbol: selectedSymbol)
            }
            .toolbar {
                Button {
                    symbolSheet = symbol
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
    }
}