import SwiftUI
import UIKit

struct ScreenshotExporterView: View {
    let commandRepository: CommandRepository
    let shortcutRepository: ShortcutRepository
    let favoritesManager: FavoritesManager
    let storeManager: StoreManager

    @State private var step = 0
    @State private var status = "Preparing screenshots…"

    private let shots: [String] = [
        "01-commands-list",
        "02-command-detail",
        "03-shortcuts-list",
        "04-shortcut-detail",
        "05-favorites",
        "06-paywall",
    ]

    var body: some View {
        Group {
            switch step {
            case 0:
                tabShell(
                    selection: 0,
                    commands: AnyView(CommandListView())
                )
            case 1:
                tabShell(
                    selection: 0,
                    commands: AnyView(
                        NavigationStack {
                            if let command = commandRepository.command(withID: "trim") {
                                CommandDetailView(command: command)
                            }
                        }
                    )
                )
            case 2:
                tabShell(
                    selection: 1,
                    shortcuts: AnyView(ShortcutsListView())
                )
            case 3:
                tabShell(
                    selection: 1,
                    shortcuts: AnyView(
                        NavigationStack {
                            if let shortcut = shortcutRepository.shortcuts.first(where: { $0.id == "undo" }) {
                                ShortcutDetailView(shortcut: shortcut)
                            }
                        }
                    )
                )
            case 4:
                tabShell(
                    selection: 2,
                    favorites: AnyView(FavoritesListView())
                )
            case 5:
                NavigationStack {
                    PaywallView()
                        .environment(StoreManager(forceProUnlocked: false))
                }
            default:
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text(status)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .environment(commandRepository)
        .environment(shortcutRepository)
        .environment(favoritesManager)
        .environment(storeManager)
        .task(id: step) {
            guard step < shots.count else { return }
            try? await Task.sleep(for: .milliseconds(1500))
            await captureCurrentScreen(named: shots[step])
            step += 1
            if step >= shots.count {
                status = "Saved \(shots.count) screenshots."
                print("SCREENSHOT_EXPORT_COMPLETE")
            }
        }
    }

    private func tabShell(
        selection: Int,
        commands: AnyView = AnyView(CommandListView()),
        shortcuts: AnyView = AnyView(ShortcutsListView()),
        favorites: AnyView = AnyView(FavoritesListView())
    ) -> some View {
        TabView(selection: .constant(selection)) {
            commands
                .tabItem { Label("Commands", systemImage: "book") }
                .tag(0)

            shortcuts
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }
                .tag(1)

            favorites
                .tabItem { Label("Favorites", systemImage: "star") }
                .tag(2)
        }
    }

    @MainActor
    private func captureCurrentScreen(named filename: String) async {
        status = "Capturing \(filename)…"

        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) else {
            status = "Could not find key window."
            return
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = window.screen.scale
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds, format: format)
        let image = renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }

        guard let data = image.pngData() else {
            status = "Failed to encode \(filename)."
            return
        }

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AppStoreScreenshots", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let fileURL = directory.appendingPathComponent("\(filename).png")
            try data.write(to: fileURL, options: .atomic)
            print("SCREENSHOT_SAVED:\(fileURL.path)")
        } catch {
            status = "Failed to save \(filename)."
        }
    }
}
