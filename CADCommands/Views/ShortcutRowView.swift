import SwiftUI

struct ShortcutKeyBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold).monospaced())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.secondarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
    }
}

struct ShortcutRowView: View {
    let shortcut: KeyboardShortcut

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(shortcut.title)
                    .font(.headline)

                Text(shortcut.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                ShortcutKeyBadge(text: shortcut.keys)

                if let macKeys = shortcut.macKeys, macKeys != shortcut.keys {
                    Text("Mac: \(macKeys)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ShortcutRowView(
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
}
