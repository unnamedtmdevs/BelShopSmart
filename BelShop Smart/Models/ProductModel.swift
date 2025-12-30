//
//  ProductModel.swift
//  BelShop Smart
//

import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var category: ProductCategory
    var imageURL: String?
    var prices: [RetailerPrice]
    var averageRating: Double
    var reviewCount: Int
    var specifications: [String: String]
    var isOnWishlist: Bool
    var isDeal: Bool
    var dealExpiryDate: Date?
    var dealDiscount: Int?
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         category: ProductCategory,
         imageURL: String? = nil,
         prices: [RetailerPrice],
         averageRating: Double = 0.0,
         reviewCount: Int = 0,
         specifications: [String: String] = [:],
         isOnWishlist: Bool = false,
         isDeal: Bool = false,
         dealExpiryDate: Date? = nil,
         dealDiscount: Int? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.imageURL = imageURL
        self.prices = prices
        self.averageRating = averageRating
        self.reviewCount = reviewCount
        self.specifications = specifications
        self.isOnWishlist = isOnWishlist
        self.isDeal = isDeal
        self.dealExpiryDate = dealExpiryDate
        self.dealDiscount = dealDiscount
    }
    
    var lowestPrice: Double {
        prices.map { $0.price }.min() ?? 0
    }
    
    var highestPrice: Double {
        prices.map { $0.price }.max() ?? 0
    }
    
    var priceSavings: Double {
        highestPrice - lowestPrice
    }
    
    var bestRetailer: RetailerPrice? {
        prices.min(by: { $0.price < $1.price })
    }
}

struct RetailerPrice: Identifiable, Codable, Hashable {
    let id: UUID
    var retailerName: String
    var price: Double
    var currency: String
    var availability: ProductAvailability
    var shippingCost: Double
    var deliveryDays: Int
    var retailerURL: String?
    
    init(id: UUID = UUID(),
         retailerName: String,
         price: Double,
         currency: String = "BYN",
         availability: ProductAvailability = .inStock,
         shippingCost: Double = 0,
         deliveryDays: Int = 3,
         retailerURL: String? = nil) {
        self.id = id
        self.retailerName = retailerName
        self.price = price
        self.currency = currency
        self.availability = availability
        self.shippingCost = shippingCost
        self.deliveryDays = deliveryDays
        self.retailerURL = retailerURL
    }
    
    var totalPrice: Double {
        price + shippingCost
    }
}

enum ProductCategory: String, Codable, CaseIterable {
    case electronics = "Электроника"
    case clothing = "Одежда"
    case home = "Дом и сад"
    case beauty = "Красота"
    case sports = "Спорт"
    case books = "Книги"
    case toys = "Игрушки"
    case food = "Продукты"
    case other = "Другое"
    
    var iconName: String {
        switch self {
        case .electronics: return "laptopcomputer"
        case .clothing: return "tshirt"
        case .home: return "house"
        case .beauty: return "sparkles"
        case .sports: return "sportscourt"
        case .books: return "book"
        case .toys: return "gamecontroller"
        case .food: return "cart"
        case .other: return "tag"
        }
    }
}

enum ProductAvailability: String, Codable {
    case inStock = "В наличии"
    case lowStock = "Мало"
    case outOfStock = "Нет в наличии"
    case preOrder = "Предзаказ"
    
    var color: String {
        switch self {
        case .inStock: return "green"
        case .lowStock: return "orange"
        case .outOfStock: return "red"
        case .preOrder: return "blue"
        }
    }
}

struct WishlistItem: Identifiable, Codable {
    let id: UUID
    var productId: UUID
    var addedDate: Date
    var notes: String
    var priority: Priority
    
    init(id: UUID = UUID(),
         productId: UUID,
         addedDate: Date = Date(),
         notes: String = "",
         priority: Priority = .medium) {
        self.id = id
        self.productId = productId
        self.addedDate = addedDate
        self.notes = notes
        self.priority = priority
    }
    
    enum Priority: String, Codable, CaseIterable {
        case high = "Высокий"
        case medium = "Средний"
        case low = "Низкий"
    }
}

