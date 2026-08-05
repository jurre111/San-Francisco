//
//  SymbolInfoView.swift
//  San Francisco
//
//  Created by jurre111 on 05.08.26.
//

import SwiftUI

struct SymbolInfoView: View {
    @ObservedObject var mgr: sfmgr = sfmgr.shared
    var symbol: String
    var info: sfmgr.Symbol?

    var body: some View {
        if let symbolInfo = info {
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
                            Text("iOS \(String(symbolInfo.availability))")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Section("Categories") {
                    ForEach(mgr.categories, id: \.self) { category in
                        if category.key != "name" && symbolInfo.categories.contains(category.key) {
                            HStack {
                                Image(systemName: category.icon)
                                    .frame(width: 20, alignment: .center)
                                Text(category.displayName)
                            }
                        }
                    }
                }
                .navigationTitle("Information")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}