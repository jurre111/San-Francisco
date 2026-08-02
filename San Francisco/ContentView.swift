import SwiftUI

struct ContentView: View {
    @State private var symbols: [String: [String]] = []
    var body: some View {
        List {

        }
        .onAppear {
            let url = Bundle.main.url(forResource: "symbols", withExtension: "plist")
            let data = try Data(contentsOf: url)
            let dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        }
    }
}

#Preview {
    ContentView()
}