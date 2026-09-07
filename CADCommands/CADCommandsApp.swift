import SwiftUI

@main
struct CADCommandsApp: App {
    @State private var commandRepository = CommandRepository()
    @State private var shortcutRepository = ShortcutRepository()
    @State private var favoritesManager = FavoritesManager()
    @State private var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            if ScreenshotMode.isExporting {
                ScreenshotExporterView(
                    commandRepository: commandRepository,
                    shortcutRepository: shortcutRepository,
                    favoritesManager: favoritesManager,
                    storeManager: storeManager
                )
            } else {
                ContentView()
                    .environment(commandRepository)
                    .environment(shortcutRepository)
                    .environment(favoritesManager)
                    .environment(storeManager)
            }
        }
    }
}
