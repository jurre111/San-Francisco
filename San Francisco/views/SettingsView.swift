//
//  SettingsView.swift
//  San Francisco
//
//  Created by jurre111 on 03.08.26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("alwaysShowTabbar") var alwaysShowTabbar: Bool = false
    @State private var appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    @State private var commitHash: String = Bundle.main.object(forInfoDictionaryKey: "CommitHash") as? String ?? "Unknown"
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle("Always show Tabbar", isOn: $alwaysShowTabbar)
                }
                Section("App Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Commit Hash")
                        Spacer()
                        Text(commitHash)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}