//
//  SanFrancisco.swift
//  San Francisco
//
//  Created by jurre111 on 02.08.26.
//

import SwiftUI

@main
struct SanFrancisco: App {
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
        }
    }
}