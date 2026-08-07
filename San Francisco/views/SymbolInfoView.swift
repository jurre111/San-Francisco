//
//  SymbolInfoView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolInfoView: View {
    let symbol: sfmgr.Symbol

    var body: some View {
        NavigationStack {
            List{
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity, alignment: .center)
                        .aspectRatio(1.0, contentMode: .fit)
                    Image(systemName: symbol.name)
                        .font(.system(size: 220))
                        .foregroundColor(.blue)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                Section("Info") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(symbol.name)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Available since")
                        Spacer()
                        Text("iOS \(String(symbol.availability))")
                            .foregroundColor(.secondary)
                    }
                }
            
                Section("Categories") {
                    ForEach(sfmgr.shared.categories, id: \.self) { category in
                        if category.name != "all" && symbol.categories.contains(category.name) {
                            HStack {
                                Image(systemName: category.icon)
                                    .frame(width: 20, alignment: .center)
                                Text(category.displayName)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}