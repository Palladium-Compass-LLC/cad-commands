import Foundation
import StoreKit

enum StoreProduct {
    static let proUnlockID = "palladiumcompassllc.CADCommands.pro"
}

@MainActor
@Observable
final class StoreManager {
    private(set) var proProduct: Product?
    private(set) var isProUnlocked = false
    private(set) var isLoading = false
    private(set) var purchaseError: String?

    private var updatesTask: Task<Void, Never>?

    init(forceProUnlocked: Bool? = nil) {
        if let forceProUnlocked {
            isProUnlocked = forceProUnlocked
        } else if ScreenshotMode.unlockPro {
            isProUnlocked = true
        }

        updatesTask = listenForTransactions()
        Task {
            await refreshProducts()
            if forceProUnlocked == nil && !ScreenshotMode.unlockPro {
                await refreshPurchasedStatus()
            }
        }
    }

    var formattedPrice: String {
        proProduct?.displayPrice ?? "$6.99"
    }

    func refreshProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [StoreProduct.proUnlockID])
            proProduct = products.first
        } catch {
            purchaseError = "Unable to load products."
        }
    }

    func refreshPurchasedStatus() async {
        var unlocked = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == StoreProduct.proUnlockID {
                unlocked = true
            }
        }

        isProUnlocked = unlocked
    }

    func purchasePro() async {
        guard let proProduct else {
            purchaseError = "Pro upgrade is unavailable right now."
            return
        }

        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let result = try await proProduct.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isProUnlocked = true
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                purchaseError = "Unexpected purchase result."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshPurchasedStatus()

            if !isProUnlocked {
                purchaseError = "No previous purchase found for this Apple ID."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func canAccess(_ command: CADCommand) -> Bool {
        command.isFree || isProUnlocked
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.refreshPurchasedStatus()
            }
        }
    }
}
