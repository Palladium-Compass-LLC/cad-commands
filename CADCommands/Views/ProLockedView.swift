import SwiftUI

struct ProLockedView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let onUpgrade: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(subtitle)
        } actions: {
            Button("Upgrade to Pro", action: onUpgrade)
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ProLockedView(
        title: "Pro Feature",
        subtitle: "Unlock this feature with CAD Commands Pro.",
        systemImage: "lock.fill",
        onUpgrade: {}
    )
}
