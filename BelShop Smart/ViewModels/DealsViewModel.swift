//
//  DealsViewModel.swift
//  BelShop Smart
//

import Foundation
import Combine

class DealsViewModel: ObservableObject {
    @Published var deals: [Product] = []
    @Published var selectedCategory: ProductCategory?
    @Published var searchText: String = ""
    
    private var dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
        loadDeals()
    }
    
    private func setupSubscriptions() {
        dataService.$products
            .sink { [weak self] _ in
                self?.loadDeals()
            }
            .store(in: &cancellables)
    }
    
    func loadDeals() {
        var currentDeals = dataService.getDeals()
        
        if let category = selectedCategory {
            currentDeals = currentDeals.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            currentDeals = currentDeals.filter {
                $0.name.lowercased().contains(query) ||
                $0.description.lowercased().contains(query)
            }
        }
        
        deals = currentDeals
    }
    
    func getDealsByDiscount() -> [Product] {
        return deals.sorted { ($0.dealDiscount ?? 0) > ($1.dealDiscount ?? 0) }
    }
    
    func getExpiringDeals() -> [Product] {
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        return deals.filter { product in
            guard let expiryDate = product.dealExpiryDate else { return false }
            return expiryDate <= threeDaysFromNow
        }.sorted { ($0.dealExpiryDate ?? Date.distantFuture) < ($1.dealExpiryDate ?? Date.distantFuture) }
    }
    
    func timeRemaining(for product: Product) -> String {
        guard let expiryDate = product.dealExpiryDate else { return "" }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: expiryDate)
        
        if let days = components.day, days > 0 {
            return "\(days) days left"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hours left"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) min left"
        }
        return "Expiring soon"
    }
}

