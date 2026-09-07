import SwiftUI

struct ShortcutDetailView: View {
    @Environment(CommandRepository.self) private var commandRepository
    @Environment(StoreManager.self) private var store

    let shortcut: KeyboardShortcut

    @State private var linkedCommand: CADCommand?

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(shortcut.title)
                        .font(.largeTitle.bold())

                    Label(shortcut.category.rawValue, systemImage: shortcut.category.icon)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ShortcutKeyBadge(text: shortcut.keys)
                        if let macKeys = shortcut.macKeys, macKeys != shortcut.keys {
                            ShortcutKeyBadge(text: macKeys)
                                .overlay(alignment: .topTrailing) {
                                    Text("Mac")
                                        .font(.system(size: 8, weight: .bold))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.accentColor)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                        .offset(x: 4, y: -6)
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .listRowBackground(Color.clear)
            }

            Section("Description") {
                Text(shortcut.description)
            }

            if let command = linkedCommand, store.canAccess(command) {
                Section("Related Command") {
                    NavigationLink {
                        CommandDetailView(command: command)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(command.name)
                                .font(.headline.monospaced())
                            Text(command.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
        .navigationTitle(shortcut.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let commandId = shortcut.commandId {
                linkedCommand = commandRepository.command(withID: commandId)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShortcutDetailView(
            shortcut: KeyboardShortcut(
                id: "undo",
                keys: "Ctrl+Z",
                macKeys: "Cmd+Z",
                title: "Undo",
                description: "Undoes the last action.",
                category: .general,
                commandId: "undo"
            )
        )
    }
    .environment(CommandRepository())
    .environment(StoreManager())
}
