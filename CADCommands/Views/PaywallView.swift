import SwiftUI

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    @Environment(CommandRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.accentColor)
                            .padding(.top, 8)

                        Text("CAD Commands Pro")
                            .font(.largeTitle.bold())

                        Text("The complete CAD command reference from Palladium Compass LLC.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "checkmark.seal.fill", title: "Built by Palladium Compass LLC", subtitle: "Independent reference content written from real drafting experience on complex designs")
                        FeatureRow(icon: "book.fill", title: "\(repository.totalCommandCount)+ commands", subtitle: "Full searchable dictionary with aliases, categories, and Very Common labels")
                        FeatureRow(icon: "lightbulb.fill", title: "Usage examples & tips", subtitle: "Learn faster with real-world guidance")
                        FeatureRow(icon: "magnifyingglass", title: "Instant search", subtitle: "Find any command by name, alias, or keyword")
                        FeatureRow(icon: "keyboard", title: "Keyboard shortcuts", subtitle: "Command aliases, function keys, and Ctrl/Cmd combos")
                        FeatureRow(icon: "star.fill", title: "Favorites", subtitle: "Save your go-to commands for quick access")
                        FeatureRow(icon: "infinity", title: "One-time purchase", subtitle: "Unlock forever — no subscription")
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(spacing: 12) {
                        Text("Free: \(repository.freeCommandCount) essential commands")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Pro: \(repository.totalCommandCount - repository.freeCommandCount) additional commands")
                            .font(.subheadline.weight(.semibold))
                    }

                    if let error = store.purchaseError {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await store.purchasePro() }
                    } label: {
                        Group {
                            if store.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Unlock Pro for \(store.formattedPrice)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(store.isLoading)

                    Button("Restore Purchases") {
                        Task { await store.restorePurchases() }
                    }
                    .font(.subheadline)
                    .disabled(store.isLoading)

                    Text("CAD Commands is an independent app and is not affiliated with any CAD software vendor.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)

                    Text("Payment will be charged to your Apple ID. Manage purchases in Settings.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: store.isProUnlocked) { _, unlocked in
                if unlocked {
                    dismiss()
                }
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    PaywallView()
        .environment(StoreManager())
        .environment(CommandRepository())
}
