//
//  SymbolView.swift
//  San Francisco
//
//  Created by jurre111 on 04.08.26.
//

import SwiftUI

struct SymbolView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var mgr: sfmgr = sfmgr.shared
    var symbol: String

    var body: some View {
        NavigationStack {
            List{
                ZStack {
                    Image(systemName: symbol)
                        .font(.system(size: 220))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1.0, contentMode: .fit)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                Section("Customize") {
                    HStack {
                        Text("Color")
                        Spacer()
                        Text("Blue")
                            .foregroundColor(.secondary)
                    }
                }
                Section("Info") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(symbol)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Available since")
                        Spacer()
                        Text("iOS \(String(mgr.symbols[symbol]!.availability))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 25))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.secondary, Color(UIColor.secondarySystemGroupedBackground))
                    }
                }
            }
        }
    }
}