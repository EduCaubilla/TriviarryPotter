//
//  Store.swift
//  TriviarryPotter
//
//  Created by Edu Caubilla on 11/3/25.
//

import Foundation
import StoreKit

enum BookStatus : Codable {
    case active
    case inactive
    case locked
}

@MainActor
class Store : ObservableObject {
    @Published var books: [BookStatus] = [.active, .active, .inactive, .locked, .locked, .locked, .locked]
    @Published var products: [Product] = []
    @Published var purchasedIDs = Set<String>()

    var productIDs = ["hp4", "hp5", "hp6", "hp7"]
    private var updates: Task<Void,Never>? = nil

    private let savePath = FileManager.documentsDirectory.appending(path: "SavedBookStatus")

    init() {
        updates = watchForUpdates()

    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            products = products.sorted(by: { $0.displayName < $1.displayName })
        } catch {
            print("Couldn't fetch the products from the store: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            print("Prodct to purchase -> \(product.id)")

            let result = try await product.purchase()

            switch result {
                //Purchase succesfuil, but now we have to verify the receipt
                case .success(let verificationResult):
                    switch verificationResult {
                        case .unverified(let signedType, let verificationError):
                            print("Unverified error on \(signedType) : \(verificationError)")

                        case .verified(let signedType):
                            purchasedIDs.insert(signedType.productID)
                    }

                //User cancelled or parent disapproved child's purchase request
                case .userCancelled:
                    break

                //Waiting for approval
                case .pending:
                    break

                //Unknown cases
                @unknown default:
                    break
            }
        } catch  {
            print("Couldn't purchase that product \(product) because of an error: \(error)")
        }
    }

    func saveBookStatuses() {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: savePath)
        } catch {
            print("Unable to save books data")
        }
    }

    func loadBookStatuses() {
        do {
            let data = try Data(contentsOf: savePath)
            books = try JSONDecoder().decode([BookStatus].self, from: data)

        } catch {
            print("Unable to load books data")
        }
    }

    private func checkPurchased() async {
        for product in products {
            guard let state = await product.currentEntitlement else { return }

            switch state {
                case .unverified(let signedType, let verificationError):
                    print("Unverified checking error on \(signedType) : \(verificationError)")


                case .verified(let signedType):
                    if signedType.revocationDate == nil {
                        purchasedIDs.insert(signedType.productID)
                    }
                    else {
                        purchasedIDs.remove(signedType.productID)
                    }
            }
        }
    }

    private func watchForUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await checkPurchased()
            }
        }
    }
}

