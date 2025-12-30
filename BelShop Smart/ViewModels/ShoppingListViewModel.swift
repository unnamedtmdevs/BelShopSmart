//
//  ShoppingListViewModel.swift
//  BelShop Smart
//

import Foundation
import Combine

class ShoppingListViewModel: ObservableObject {
    @Published var wishlistProducts: [Product] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: ProductCategory?
    @Published var sortOption: SortOption = .dateAdded
    
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Дата добавления"
        case priceAsc = "Цена: низкая → высокая"
        case priceDesc = "Цена: высокая → низкая"
        case name = "Название"
        case priority = "Приоритет"
    }
    
    init() {
        setupSubscriptions()
        loadWishlist()
    }
    
    private func setupSubscriptions() {
        dataService.$products
            .sink { [weak self] _ in
                self?.loadWishlist()
            }
            .store(in: &cancellables)
        
        dataService.$wishlistItems
            .sink { [weak self] _ in
                self?.loadWishlist()
            }
            .store(in: &cancellables)
    }
    
    func loadWishlist() {
        var products = dataService.getWishlistProducts()
        
        if let category = selectedCategory {
            products = products.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            products = products.filter {
                $0.name.lowercased().contains(query) ||
                $0.description.lowercased().contains(query)
            }
        }
        
        products = sortProducts(products)
        wishlistProducts = products
    }
    
    private func sortProducts(_ products: [Product]) -> [Product] {
        switch sortOption {
        case .dateAdded:
            let wishlistItems = dataService.wishlistItems
            return products.sorted { product1, product2 in
                let date1 = wishlistItems.first(where: { $0.productId == product1.id })?.addedDate ?? Date.distantPast
                let date2 = wishlistItems.first(where: { $0.productId == product2.id })?.addedDate ?? Date.distantPast
                return date1 > date2
            }
        case .priceAsc:
            return products.sorted { $0.lowestPrice < $1.lowestPrice }
        case .priceDesc:
            return products.sorted { $0.lowestPrice > $1.lowestPrice }
        case .name:
            return products.sorted { $0.name < $1.name }
        case .priority:
            let wishlistItems = dataService.wishlistItems
            return products.sorted { product1, product2 in
                let priority1 = wishlistItems.first(where: { $0.productId == product1.id })?.priority ?? .low
                let priority2 = wishlistItems.first(where: { $0.productId == product2.id })?.priority ?? .low
                return priorityValue(priority1) > priorityValue(priority2)
            }
        }
    }
    
    private func priorityValue(_ priority: WishlistItem.Priority) -> Int {
        switch priority {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    func removeFromWishlist(_ product: Product) {
        dataService.removeFromWishlist(productId: product.id)
    }
    
    func getWishlistItem(for productId: UUID) -> WishlistItem? {
        return dataService.wishlistItems.first { $0.productId == productId }
    }
    
    func updateWishlistItem(_ item: WishlistItem) {
        dataService.updateWishlistItem(item)
    }
}

