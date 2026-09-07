import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CommandListView()
                .tabItem {
                    Label("Commands", systemImage: "book")
                }

            ShortcutsListView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            FavoritesListView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(CommandRepository())
        .environment(ShortcutRepository())
        .environment(FavoritesManager())
        .environment(StoreManager())
}
