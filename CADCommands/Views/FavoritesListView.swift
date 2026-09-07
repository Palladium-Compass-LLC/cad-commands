import SwiftUI

struct FavoritesListView: View {
    @Environment(FavoritesManager.self) private var favorites
    @Environment(CommandRepository.self) private var repository
    @Environment(StoreManager.self) private var store

    @State private var showPaywall = false
    @State private var selectedCommand: CADCommand?

    private var favoriteCommands: [CADCommand] {
        favorites.favoriteCommands(from: repository)
    }

    var body: some View {
        NavigationStack {
            Group {
                if !store.isProUnlocked {
                    ProLockedView(
                        title: "Favorites",
                        subtitle: "Unlock Pro to save your most-used commands for quick access from a dedicated tab.",
                        systemImage: "star.fill",
                        onUpgrade: { showPaywall = true }
                    )
                } else if favoriteCommands.isEmpty {
                    ContentUnavailableView {
                        Label("No Favorites Yet", systemImage: "star")
                    } description: {
                        Text("Tap the star on any command to add it here.")
                    }
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Favorites")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .navigationDestination(item: $selectedCommand) { command in
                CommandDetailView(command: command)
            }
        }
    }

    private var favoritesList: some View {
        List {
            Section {
                Text("\(favoriteCommands.count) saved command\(favoriteCommands.count == 1 ? "" : "s")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                ForEach(favoriteCommands) { command in
                    Button {
                        selectedCommand = command
                    } label: {
                        CommandRowView(command: command, showsFreeBadge: false)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            favorites.remove(command)
                        } label: {
                            Label("Remove", systemImage: "star.slash")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    FavoritesListView()
        .environment(FavoritesManager())
        .environment(CommandRepository())
        .environment(StoreManager())
}
