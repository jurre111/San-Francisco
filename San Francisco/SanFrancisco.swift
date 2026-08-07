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
    var body: some Scene {
        WindowGroup {
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
            .environmentObject(mgr)
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}