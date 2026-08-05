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
                Tab("Home", systemImage: "house.fill") {
                    ContentView()
                }
                Tab("Favorites", systemImage: "star.fill") {
                    FavoritesView()
                }
            }
        }
    }
}