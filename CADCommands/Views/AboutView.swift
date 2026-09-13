import SwiftUI

struct AboutView: View {
    private static let supportURL = URL(string: "https://palladiumcompass.com/#contact")!
    private static let privacyURL = URL(string: "https://palladiumcompass.com/privacy.html")!

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.accentColor)

                        Text("CAD Commands")
                            .font(.title.bold())

                        Text("Your pocket reference for CAD command names, aliases, shortcuts, and practical usage guidance.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)

                    legalSection(
                        title: "About This App",
                        body: """
                        CAD Commands is a searchable dictionary built for students and professionals who use CAD software every day. Browse more than 500 commands organized by category, filter the most essential tools, and look up aliases, usage notes, examples, and tips in seconds.

                        Pro unlocks the full command library, keyboard shortcuts for Windows and Mac, and a favorites tab so your go-to commands are always one tap away.

                        This app was created by Palladium Compass LLC from hands-on experience using these commands on real projects — from everyday drafting workflows to complex, detail-heavy designs. The descriptions and tips reflect practical use in the field, not copied manual text.
                        """
                    )

                    legalSection(
                        title: "Independent App",
                        body: """
                        CAD Commands is an independent reference app. It is not affiliated with, endorsed by, or sponsored by any CAD software vendor. Command names are used only to identify common drafting functions, similar to a dictionary or study guide.
                        """
                    )

                    legalSection(
                        title: "Original Content",
                        body: """
                        All command descriptions, examples, and tips in this app were written independently for educational reference. This app does not reproduce official vendor documentation, help files, training materials, or proprietary content.
                        """
                    )

                    legalSection(
                        title: "Fair Use of Command Names",
                        body: """
                        Short command names and aliases (such as LINE or COPY) are functional terms that describe software operations. Listing them for lookup and learning purposes is standard practice in independent reference apps and textbooks.
                        """
                    )

                    legalSection(
                        title: "What This App Does Not Include",
                        body: """
                        No third-party CAD logos, icons, user interface screenshots, or copyrighted manual text are included. Do not represent this app as an official product of any CAD software company in marketing or App Store listings.
                        """
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Support")
                            .font(.headline)
                        Text("Questions, feedback, or help with purchases and restores:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Link("Email support", destination: Self.supportURL)
                            .font(.subheadline)
                        Link("Support website", destination: URL(string: "https://palladiumcompass.com/")!)
                            .font(.subheadline)
                        Link("Privacy Policy", destination: Self.privacyURL)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("© \(String(Calendar.current.component(.year, from: Date()))) Palladium Compass LLC")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("About & Legal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func legalSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AboutView()
}
