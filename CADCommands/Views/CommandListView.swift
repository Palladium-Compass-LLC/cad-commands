import SwiftUI

struct CommandListView: View {
    @Environment(CommandRepository.self) private var repository
    @Environment(StoreManager.self) private var store
    @Environment(FavoritesManager.self) private var favorites

    @State private var searchText = ""
    @State private var selectedCategory: CommandCategory?
    @State private var showVeryCommonOnly = false
    @State private var showPaywall = false
    @State private var showAbout = false
    @State private var selectedCommand: CADCommand?

    private var filteredCommands: [CADCommand] {
        var results = repository.search(searchText, category: selectedCategory)
        if showVeryCommonOnly {
            results = results.filter(\.isVeryCommon)
        }
        guard store.isProUnlocked else {
            return results.filter(\.isFree)
        }
        return results
    }

    var body: some View {
        NavigationStack {
            Group {
                if let error = repository.loadError {
                    ContentUnavailableView("Unable to Load", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    commandList
                }
            }
            .navigationTitle("CAD Commands")
            .searchable(text: $searchText, prompt: "Search commands, aliases, or keywords")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About and legal information")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !store.isProUnlocked {
                        Button("Pro") {
                            showPaywall = true
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                categoryPicker
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .navigationDestination(item: $selectedCommand) { command in
                CommandDetailView(command: command)
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "All", isSelected: !showVeryCommonOnly && selectedCategory == nil) {
                    selectedCategory = nil
                    showVeryCommonOnly = false
                }

                CategoryChip(
                    title: "Very Common",
                    icon: "flame.fill",
                    isSelected: showVeryCommonOnly
                ) {
                    showVeryCommonOnly = true
                    selectedCategory = nil
                }

                ForEach(CommandCategory.allCases) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: !showVeryCommonOnly && selectedCategory == category
                    ) {
                        selectedCategory = category
                        showVeryCommonOnly = false
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }

    private var commandList: some View {
        List {
            if !store.isProUnlocked {
                Section {
                    ProBannerView(onUpgrade: { showPaywall = true })
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                if filteredCommands.isEmpty {
                    if searchText.isEmpty {
                        ContentUnavailableView("No Commands", systemImage: "tray", description: Text("No commands in this category."))
                    } else {
                        ContentUnavailableView.search(text: searchText)
                    }
                } else {
                    ForEach(filteredCommands) { command in
                        Button {
                            selectedCommand = command
                        } label: {
                            CommandRowView(
                                command: command,
                                showsFreeBadge: !store.isProUnlocked,
                                isFavorite: store.isProUnlocked && favorites.isFavorite(command)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                HStack {
                    Text("\(filteredCommands.count) commands")
                    Spacer()
                    if !store.isProUnlocked {
                        Text("\(repository.freeCommandCount) free")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct CategoryChip: View {
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

private struct ProBannerView: View {
    let onUpgrade: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Unlock the Full Dictionary", systemImage: "lock.open.display")
                .font(.headline)

            Text("Search 500+ commands, shortcuts, and favorites — from Palladium Compass LLC.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Upgrade to Pro", action: onUpgrade)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.accentColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    CommandListView()
        .environment(CommandRepository())
        .environment(StoreManager())
}
