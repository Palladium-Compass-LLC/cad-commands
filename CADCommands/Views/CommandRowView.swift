import SwiftUI

struct CommandBadge: View {
    let title: String
    let foreground: Color
    let background: Color

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(Capsule())
    }
}

struct CommandRowView: View {
    let command: CADCommand
    var showsFreeBadge = true
    var isFavorite = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(command.name)
                        .font(.headline.monospaced())
                        .foregroundStyle(.primary)

                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }

                    if command.isVeryCommon {
                        CommandBadge(
                            title: "Very Common",
                            foreground: .orange,
                            background: Color.orange.opacity(0.15)
                        )
                    }

                    if showsFreeBadge && command.isFree {
                        CommandBadge(
                            title: "FREE",
                            foreground: .green,
                            background: Color.green.opacity(0.15)
                        )
                    }
                }

                if !command.aliases.isEmpty {
                    Text("Aliases: \(command.aliases.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(command.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: command.category.icon)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        CommandRowView(
            command: CADCommand(
                id: "line",
                name: "LINE",
                aliases: ["L"],
                category: .drawing,
                description: "Creates straight line segments between specified points.",
                usage: "LINE",
                isFree: true,
                isVeryCommon: true
            )
        )
    }
}
