//
//  ContentView.swift
//  San Francisco
//
//  Created by jurre111 on 02.08.26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var mgr: sfmgr = sfmgr.shared
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
                            Text("Item \(item)")
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
        .onAppear {
            let result = mgr.load()
            if !result.ok {
                Alertinator.shared.alert(title: "Error", body: result.message)
            }
        }
    }
}



#Preview {
    ContentView()
}