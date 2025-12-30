//
//  ProductDetailViewModel.swift
//  BelShop Smart
//

import Foundation
import Combine

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product
    @Published var isInWishlist: Bool = false
    @Published var sortedPrices: [RetailerPrice] = []
    @Published var selectedRetailer: RetailerPrice?
    
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(product: Product) {
        self.product = product
        self.isInWishlist = product.isOnWishlist
        setupSubscriptions()
        loadPrices()
    }
    
    private func setupSubscriptions() {
        dataService.$products
            .sink { [weak self] products in
                guard let self = self else { return }
                if let updated = products.first(where: { $0.id == self.product.id }) {
                    self.product = updated
                    self.isInWishlist = updated.isOnWishlist
                    self.loadPrices()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadPrices() {
        sortedPrices = product.prices.sorted { $0.totalPrice < $1.totalPrice }
        selectedRetailer = sortedPrices.first
    }
    
    func toggleWishlist() {
        if isInWishlist {
            dataService.removeFromWishlist(productId: product.id)
        } else {
            dataService.addToWishlist(productId: product.id)
        }
    }
    
    func getPriceDifference(from retailer: RetailerPrice) -> Double {
        guard let bestPrice = product.bestRetailer?.totalPrice else { return 0 }
        return retailer.totalPrice - bestPrice
    }
    
    func isBestPrice(_ retailer: RetailerPrice) -> Bool {
        return retailer.id == product.bestRetailer?.id
    }
    
    var dealTimeRemaining: String? {
        guard product.isDeal, let expiryDate = product.dealExpiryDate else { return nil }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour], from: now, to: expiryDate)
        
        if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        }
        return "Expiring soon"
    }
}

