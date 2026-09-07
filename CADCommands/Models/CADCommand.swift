import Foundation

enum CommandCategory: String, Codable, CaseIterable, Identifiable {
    case drawing = "Drawing"
    case modifying = "Modifying"
    case annotation = "Annotation"
    case layers = "Layers & Properties"
    case blocks = "Blocks & References"
    case view = "View & Navigation"
    case inquiry = "Inquiry"
    case threeD = "3D"
    case system = "Settings & System"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .drawing: "pencil.and ruler"
        case .modifying: "arrow.triangle.2.circlepath"
        case .annotation: "textformat"
        case .layers: "square.3.layers.3d"
        case .blocks: "square.grid.2x2"
        case .view: "eye"
        case .inquiry: "magnifyingglass"
        case .threeD: "cube"
        case .system: "gearshape"
        }
    }
}

struct CADCommand: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let aliases: [String]
    let category: CommandCategory
    let description: String
    let usage: String
    let example: String?
    let tips: String?
    let isFree: Bool
    let isVeryCommon: Bool

    var searchableText: String {
        ([name] + aliases + [category.rawValue, description, usage] + (isVeryCommon ? ["very common", "essential", "popular"] : []))
            .joined(separator: " ")
            .lowercased()
    }

    init(
        id: String,
        name: String,
        aliases: [String],
        category: CommandCategory,
        description: String,
        usage: String,
        example: String? = nil,
        tips: String? = nil,
        isFree: Bool,
        isVeryCommon: Bool = false
    ) {
        self.id = id
        self.name = name
        self.aliases = aliases
        self.category = category
        self.description = description
        self.usage = usage
        self.example = example
        self.tips = tips
        self.isFree = isFree
        self.isVeryCommon = isVeryCommon
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        aliases = try container.decode([String].self, forKey: .aliases)
        category = try container.decode(CommandCategory.self, forKey: .category)
        description = try container.decode(String.self, forKey: .description)
        usage = try container.decode(String.self, forKey: .usage)
        example = try container.decodeIfPresent(String.self, forKey: .example)
        tips = try container.decodeIfPresent(String.self, forKey: .tips)
        isFree = try container.decode(Bool.self, forKey: .isFree)
        isVeryCommon = try container.decodeIfPresent(Bool.self, forKey: .isVeryCommon) ?? isFree
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, aliases, category, description, usage, example, tips, isFree, isVeryCommon
    }
}

struct CommandDatabase: Codable {
    let commands: [CADCommand]
}
