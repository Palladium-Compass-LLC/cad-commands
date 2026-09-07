import Foundation

@MainActor
@Observable
final class ShortcutRepository {
    private(set) var shortcuts: [KeyboardShortcut] = []
    private(set) var loadError: String?

    init() {
        loadShortcuts()
    }

    func loadShortcuts() {
        guard let url = Bundle.main.url(forResource: "shortcuts", withExtension: "json") else {
            loadError = "Could not find shortcuts database."
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let database = try JSONDecoder().decode(ShortcutDatabase.self, from: data)
            shortcuts = database.shortcuts.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            loadError = nil
        } catch {
            loadError = "Failed to load shortcuts: \(error.localizedDescription)"
        }
    }

    func shortcuts(in category: ShortcutCategory?) -> [KeyboardShortcut] {
        guard let category else { return shortcuts }
        return shortcuts.filter { $0.category == category }
    }

    func search(_ query: String, category: ShortcutCategory?) -> [KeyboardShortcut] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var results = shortcuts(in: category)

        guard !trimmed.isEmpty else { return results }

        let terms = trimmed.lowercased().split(separator: " ").map(String.init)
        return results.filter { shortcut in
            terms.allSatisfy { shortcut.searchableText.contains($0) }
        }
    }
}
