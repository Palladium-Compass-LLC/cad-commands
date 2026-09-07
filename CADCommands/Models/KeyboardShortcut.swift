import Foundation

enum ShortcutCategory: String, Codable, CaseIterable, Identifiable {
    case drawing = "Drawing"
    case modifying = "Modifying"
    case annotation = "Annotation"
    case navigation = "Navigation"
    case toggles = "Toggles & Snaps"
    case general = "General"
    case system = "System"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .drawing: "pencil.and ruler"
        case .modifying: "arrow.triangle.2.circlepath"
        case .annotation: "textformat"
        case .navigation: "arrow.up.left.and.arrow.down.right"
        case .toggles: "switch.2"
        case .general: "command"
        case .system: "gearshape"
        }
    }
}

struct KeyboardShortcut: Identifiable, Codable, Hashable {
    let id: String
    let keys: String
    let macKeys: String?
    let title: String
    let description: String
    let category: ShortcutCategory
    let commandId: String?

    var searchableText: String {
        ([keys, macKeys, title, description, category.rawValue]
            .compactMap { $0 })
            .joined(separator: " ")
            .lowercased()
    }

    var displayKeys: String {
        #if os(macOS)
        macKeys ?? keys
        #else
        keys
        #endif
    }
}

struct ShortcutDatabase: Codable {
    let shortcuts: [KeyboardShortcut]
}
