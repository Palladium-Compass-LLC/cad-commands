import Foundation

@MainActor
@Observable
final class FavoritesManager {
    private let storageKey = "favoriteCommandIDs"
    private(set) var favoriteIDs: [String] = []

    init() {
        if ScreenshotMode.isExporting {
            favoriteIDs = ["line", "trim", "layer", "dimension", "copy"]
        } else {
            load()
        }
    }

    func isFavorite(_ command: CADCommand) -> Bool {
        favoriteIDs.contains(command.id)
    }

    @discardableResult
    func toggle(_ command: CADCommand) -> Bool {
        if let index = favoriteIDs.firstIndex(of: command.id) {
            favoriteIDs.remove(at: index)
        } else {
            favoriteIDs.insert(command.id, at: 0)
        }
        save()
        return isFavorite(command)
    }

    func remove(_ command: CADCommand) {
        favoriteIDs.removeAll { $0 == command.id }
        save()
    }

    func favoriteCommands(from repository: CommandRepository) -> [CADCommand] {
        favoriteIDs.compactMap { repository.command(withID: $0) }
    }

    private func load() {
        favoriteIDs = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
    }

    private func save() {
        UserDefaults.standard.set(favoriteIDs, forKey: storageKey)
    }
}
