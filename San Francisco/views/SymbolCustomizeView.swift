//
//  SymbolCustomizeView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolCustomizeView: View {
    @State private var symbolSheet: String? = nil
    var symbol: String

    var body: some View {
        NavigationStack {
            List{
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1.0, contentMode: .fit)
                    Image(systemName: symbol)
                        .font(.system(size: 220))
                        .foregroundColor(.blue)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                Section {
                    NavigationLink {}
                    HStack {
                        Text("Color")
                        Spacer()
                        Text("Blue")
                            .foregroundColor(.secondary)
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
                }
            }
        }
    }
}