import SwiftUI

struct ShortcutsListView: View {
    @Environment(ShortcutRepository.self) private var shortcutRepository
    @Environment(StoreManager.self) private var store

    @State private var searchText = ""
    @State private var selectedCategory: ShortcutCategory?
    @State private var showPaywall = false
    @State private var selectedShortcut: KeyboardShortcut?

    private var filteredShortcuts: [KeyboardShortcut] {
        shortcutRepository.search(searchText, category: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            Group {
                if !store.isProUnlocked {
                    ProLockedView(
                        title: "Keyboard Shortcuts",
                        subtitle: "Unlock Pro to browse every shortcut — command aliases, function keys, Ctrl/Cmd combos, and navigation tips.",
                        systemImage: "keyboard",
                        onUpgrade: { showPaywall = true }
                    )
                } else if let error = shortcutRepository.loadError {
                    ContentUnavailableView("Unable to Load", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    shortcutsList
                }
            }
            .navigationTitle("Shortcuts")
            .searchable(text: $searchText, prompt: "Search shortcuts or keys")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .navigationDestination(item: $selectedShortcut) { shortcut in
                ShortcutDetailView(shortcut: shortcut)
            }
        }
    }

    private var shortcutsList: some View {
        List {
            Section {
                Text("Standard CAD keyboard shortcuts for Windows and Mac. Mac equivalents are shown when they differ.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ShortcutCategoryChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(ShortcutCategory.allCases) { category in
                            ShortcutCategoryChip(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section {
                if filteredShortcuts.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(filteredShortcuts) { shortcut in
                        Button {
                            selectedShortcut = shortcut
                        } label: {
                            ShortcutRowView(shortcut: shortcut)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                Text("\(filteredShortcuts.count) shortcuts")
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct ShortcutCategoryChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                if let icon {
                    Image(systemName: icon)
                }
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemFill))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ShortcutsListView()
        .environment(ShortcutRepository())
        .environment(CommandRepository())
        .environment(StoreManager())
}
