import Foundation

@MainActor
@Observable
final class CommandRepository {
    private(set) var commands: [CADCommand] = []
    private(set) var loadError: String?

    var freeCommandCount: Int {
        commands.filter(\.isFree).count
    }

    var totalCommandCount: Int {
        commands.count
    }

    var veryCommonCommandCount: Int {
        commands.filter(\.isVeryCommon).count
    }

    init() {
        loadCommands()
    }

    func loadCommands() {
        guard let url = Bundle.main.url(forResource: "commands", withExtension: "json") else {
            loadError = "Could not find commands database."
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let database = try JSONDecoder().decode(CommandDatabase.self, from: data)
            commands = database.commands.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            loadError = nil
        } catch {
            loadError = "Failed to load commands: \(error.localizedDescription)"
        }
    }

    func commands(in category: CommandCategory?) -> [CADCommand] {
        guard let category else { return commands }
        return commands.filter { $0.category == category }
    }

    func search(_ query: String, category: CommandCategory?) -> [CADCommand] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var results = commands(in: category)

        guard !trimmed.isEmpty else { return results }

        let terms = trimmed.lowercased().split(separator: " ").map(String.init)
        return results.filter { command in
            terms.allSatisfy { command.searchableText.contains($0) }
        }
    }

    func command(withID id: String) -> CADCommand? {
        commands.first { $0.id == id }
    }
}
