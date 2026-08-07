//
//  ContentView.swift
//  San Francisco
//
//  Created by jurre111 on 02.08.26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mgr: sfmgr
    @State private var showSettings: Bool = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(mgr.categories, id: \.self) { category in
                    NavigationLink {
                        SymbolsView(category: category)
                    } label: {
                        HStack {
                            Image(systemName: category.icon)
                                .frame(width: 20, alignment: .center)
                            Text(category.displayName)
                        }
                    }
                }
                NavigationLink {
                    List {
                        ForEach(0...8000, id: \.self) { item in
                            NavigationLink {
                                List {}
                            } label: {
                                HStack {
                                    Image(systemName: "ladybug")
                                        .frame(width: 20, alignment: .center)
                                    Text("item \(item)")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "ladybug")
                            .frame(width: 20, alignment: .center)
                        Text("Test")
                    }
                }
            }
            .navigationTitle("San Francisco")
            .toolbar {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}



#Preview {
    ContentView()
}