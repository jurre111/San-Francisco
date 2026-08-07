//
//  SanFrancisco.swift
//  San Francisco
//
//  Created by jurre111 on 02.08.26.
//

import SwiftUI

@main
struct SanFrancisco: App {
    @StateObject var mgr: sfmgr = sfmgr.shared
    @State private var loaded: Bool = false
    var body: some Scene {
        WindowGroup {
            Group {
                if loaded {
                    TabView {
                        ContentView()
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                        FavoritesView()
                            .tabItem {
                                Label("Favorites", systemImage: "star.fill")
                            }
                    }
                } else {
                    NavigationStack {
                        List {
                            ProgressView()
                        }
                        .navigationTitle("San Francisco")
                    }
                }
            }
            .environmentObject(mgr)
            .onAppear {
                let result = mgr.load()
                if !result.ok {
                    Alertinator.shared.alert(title: "Error", body: result.message)
                } else {
                    loaded = true
                }
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}