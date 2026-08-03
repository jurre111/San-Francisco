import SwiftUI

struct SettingsView: View {
    @State private var appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    @State private var commitHash: String = Bundle.main.object(forInfoDictionaryKey: "COMMIT_HASH") as? String ?? "Unknown"
    var body: some View {
        NavigationStack {
            List {
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
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}