import SwiftUI

struct CommandDetailView: View {
    @Environment(FavoritesManager.self) private var favorites
    @Environment(StoreManager.self) private var store

    let command: CADCommand

    @State private var showPaywall = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(command.name)
                        .font(.largeTitle.bold().monospaced())

                    HStack(spacing: 6) {
                        if command.isVeryCommon {
                            CommandBadge(
                                title: "Very Common",
                                foreground: .orange,
                                background: Color.orange.opacity(0.15)
                            )
                        }
                        if command.isFree {
                            CommandBadge(
                                title: "FREE",
                                foreground: .green,
                                background: Color.green.opacity(0.15)
                            )
                        }
                    }

                    Label(command.category.rawValue, systemImage: command.category.icon)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.clear)
            }

            if !command.aliases.isEmpty {
                Section("Aliases") {
                    Text(command.aliases.joined(separator: ", "))
                        .font(.body.monospaced())
                }
            }

            Section("Description") {
                Text(command.description)
            }

            Section("Usage") {
                Text(command.usage)
                    .font(.body.monospaced())
            }

            if let example = command.example {
                Section("Example") {
                    Text(example)
                }
            }

            if let tips = command.tips {
                Section("Pro Tip") {
                    Label {
                        Text(tips)
                    } icon: {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
        .navigationTitle(command.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if store.isProUnlocked {
                        favorites.toggle(command)
                    } else {
                        showPaywall = true
                    }
                } label: {
                    Image(systemName: store.isProUnlocked && favorites.isFavorite(command) ? "star.fill" : "star")
                        .foregroundStyle(store.isProUnlocked && favorites.isFavorite(command) ? .yellow : .primary)
                }
                .accessibilityLabel(favorites.isFavorite(command) ? "Remove from favorites" : "Add to favorites")
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    NavigationStack {
        CommandDetailView(
            command: CADCommand(
                id: "line",
                name: "LINE",
                aliases: ["L"],
                category: .drawing,
                description: "Creates straight line segments between specified points.",
                usage: "LINE",
                example: "Specify first point, then next points.",
                tips: "Use Ortho mode (F8) for horizontal and vertical lines.",
                isFree: true,
                isVeryCommon: true
            )
        )
    }
    .environment(FavoritesManager())
    .environment(StoreManager())
}
