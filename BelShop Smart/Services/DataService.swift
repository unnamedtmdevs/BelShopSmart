//
//  DataService.swift
//  BelShop Smart
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var wishlistItems: [WishlistItem] = []
    
    private let productsKey = "saved_products"
    private let wishlistKey = "saved_wishlist"
    
    private init() {
        loadData()
        generateSampleDataIfNeeded()
    }
    
    // MARK: - Data Loading & Saving
    
    private func loadData() {
        loadProducts()
        loadWishlist()
    }
    
    private func loadProducts() {
        if let data = UserDefaults.standard.data(forKey: productsKey),
           let decoded = try? JSONDecoder().decode([Product].self, from: data) {
            products = decoded
        }
    }
    
    private func loadWishlist() {
        if let data = UserDefaults.standard.data(forKey: wishlistKey),
           let decoded = try? JSONDecoder().decode([WishlistItem].self, from: data) {
            wishlistItems = decoded
        }
    }
    
    private func saveProducts() {
        if let encoded = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(encoded, forKey: productsKey)
        }
    }
    
    private func saveWishlist() {
        if let encoded = try? JSONEncoder().encode(wishlistItems) {
            UserDefaults.standard.set(encoded, forKey: wishlistKey)
        }
    }
    
    // MARK: - Product Operations
    
    func getAllProducts() -> [Product] {
        return products
    }
    
    func getProduct(by id: UUID) -> Product? {
        return products.first { $0.id == id }
    }
    
    func getProducts(by category: ProductCategory) -> [Product] {
        return products.filter { $0.category == category }
    }
    
    func getDeals() -> [Product] {
        return products.filter { $0.isDeal && ($0.dealExpiryDate ?? Date.distantFuture) > Date() }
            .sorted { ($0.dealDiscount ?? 0) > ($1.dealDiscount ?? 0) }
    }
    
    func searchProducts(query: String) -> [Product] {
        let lowercasedQuery = query.lowercased()
        return products.filter {
            $0.name.lowercased().contains(lowercasedQuery) ||
            $0.description.lowercased().contains(lowercasedQuery)
        }
    }
    
    func addProduct(_ product: Product) {
        products.append(product)
        saveProducts()
    }
    
    func updateProduct(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
            saveProducts()
        }
    }
    
    func deleteProduct(id: UUID) {
        products.removeAll { $0.id == id }
        saveProducts()
    }
    
    // MARK: - Wishlist Operations
    
    func getWishlistProducts() -> [Product] {
        let wishlistProductIds = wishlistItems.map { $0.productId }
        return products.filter { wishlistProductIds.contains($0.id) }
    }
    
    func addToWishlist(productId: UUID, notes: String = "", priority: WishlistItem.Priority = .medium) {
        let item = WishlistItem(productId: productId, notes: notes, priority: priority)
        wishlistItems.append(item)
        
        if let index = products.firstIndex(where: { $0.id == productId }) {
            products[index].isOnWishlist = true
        }
        
        saveWishlist()
        saveProducts()
    }
    
    func removeFromWishlist(productId: UUID) {
        wishlistItems.removeAll { $0.productId == productId }
        
        if let index = products.firstIndex(where: { $0.id == productId }) {
            products[index].isOnWishlist = false
        }
        
        saveWishlist()
        saveProducts()
    }
    
    func isInWishlist(productId: UUID) -> Bool {
        return wishlistItems.contains { $0.productId == productId }
    }
    
    func updateWishlistItem(_ item: WishlistItem) {
        if let index = wishlistItems.firstIndex(where: { $0.id == item.id }) {
            wishlistItems[index] = item
            saveWishlist()
        }
    }
    
    // MARK: - Sample Data Generation
    
    private func generateSampleDataIfNeeded() {
        guard products.isEmpty else { return }
        
        let sampleProducts = [
            Product(
                name: "iPhone 14 Pro 256GB",
                description: "Флагманский смартфон Apple с Dynamic Island, процессором A16 Bionic и улучшенной камерой 48MP. Идеален для фото и видео съемки.",
                category: .electronics,
                prices: [
                    RetailerPrice(retailerName: "iStore", price: 3299.00, shippingCost: 0, deliveryDays: 1),
                    RetailerPrice(retailerName: "TechnoMart", price: 3450.00, shippingCost: 15, deliveryDays: 2),
                    RetailerPrice(retailerName: "МТС Shop", price: 3399.00, shippingCost: 0, deliveryDays: 1),
                    RetailerPrice(retailerName: "5 Element", price: 3550.00, shippingCost: 20, deliveryDays: 3)
                ],
                averageRating: 4.8,
                reviewCount: 342,
                specifications: ["Экран": "6.1\"", "Память": "256GB", "Процессор": "A16 Bionic"],
                isDeal: true,
                dealExpiryDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                dealDiscount: 15
            ),
            Product(
                name: "Samsung Galaxy S23 Ultra",
                description: "Премиальный Android-смартфон с S Pen, 200MP камерой и мощным процессором Snapdragon 8 Gen 2.",
                category: .electronics,
                prices: [
                    RetailerPrice(retailerName: "Samsung Store", price: 3699.00, shippingCost: 0, deliveryDays: 1),
                    RetailerPrice(retailerName: "TechnoMart", price: 3799.00, shippingCost: 15, deliveryDays: 2),
                    RetailerPrice(retailerName: "Евросеть", price: 3650.00, shippingCost: 10, deliveryDays: 2)
                ],
                averageRating: 4.7,
                reviewCount: 289,
                specifications: ["Экран": "6.8\"", "Память": "512GB", "Процессор": "Snapdragon 8 Gen 2"]
            ),
            Product(
                name: "Apple AirPods Pro 2",
                description: "Беспроводные наушники с активным шумоподавлением, прозрачным режимом и пространственным звуком.",
                category: .electronics,
                prices: [
                    RetailerPrice(retailerName: "iStore", price: 799.00, shippingCost: 0, deliveryDays: 1),
                    RetailerPrice(retailerName: "МТС Shop", price: 849.00, shippingCost: 0, deliveryDays: 1),
                    RetailerPrice(retailerName: "TechnoMart", price: 829.00, shippingCost: 10, deliveryDays: 2)
                ],
                averageRating: 4.9,
                reviewCount: 521,
                specifications: ["Шумоподавление": "Да", "Время работы": "6 часов", "Зарядка": "USB-C"],
                isDeal: true,
                dealExpiryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                dealDiscount: 10
            ),
            Product(
                name: "Nike Air Max 270",
                description: "Стильные спортивные кроссовки с революционной подошвой Air Max для максимального комфорта.",
                category: .sports,
                prices: [
                    RetailerPrice(retailerName: "Nike Store", price: 349.00, shippingCost: 0, deliveryDays: 2),
                    RetailerPrice(retailerName: "SportMaster", price: 369.00, shippingCost: 15, deliveryDays: 3),
                    RetailerPrice(retailerName: "Adidas.by", price: 359.00, shippingCost: 10, deliveryDays: 2)
                ],
                averageRating: 4.6,
                reviewCount: 187,
                specifications: ["Размеры": "36-46", "Материал": "Текстиль + синтетика", "Цвета": "5 вариантов"]
            ),
            Product(
                name: "Dyson V15 Detect",
                description: "Мощный беспроводной пылесос с лазерным детектором пыли и умной системой фильтрации.",
                category: .home,
                prices: [
                    RetailerPrice(retailerName: "Dyson Store", price: 1899.00, shippingCost: 0, deliveryDays: 2),
                    RetailerPrice(retailerName: "5 Element", price: 1950.00, shippingCost: 20, deliveryDays: 3),
                    RetailerPrice(retailerName: "TechnoMart", price: 1999.00, shippingCost: 15, deliveryDays: 2)
                ],
                averageRating: 4.8,
                reviewCount: 156,
                specifications: ["Время работы": "60 мин", "Мощность": "230W", "Вес": "3.1 кг"],
                isDeal: true,
                dealExpiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
                dealDiscount: 20
            ),
            Product(
                name: "Sony PlayStation 5",
                description: "Игровая консоль нового поколения с SSD накопителем, поддержкой 4K и уникальными играми.",
                category: .electronics,
                prices: [
                    RetailerPrice(retailerName: "GameStop", price: 1599.00, shippingCost: 0, deliveryDays: 1),
                    RetailerPrice(retailerName: "TechnoMart", price: 1650.00, availability: .lowStock, shippingCost: 15, deliveryDays: 2),
                    RetailerPrice(retailerName: "5 Element", price: 1699.00, shippingCost: 20, deliveryDays: 3)
                ],
                averageRating: 4.9,
                reviewCount: 678,
                specifications: ["Память": "825GB SSD", "Разрешение": "4K", "Контроллер": "DualSense"]
            ),
            Product(
                name: "Levi's 501 Original Jeans",
                description: "Классические прямые джинсы из премиального денима, легендарная модель Levi's.",
                category: .clothing,
                prices: [
                    RetailerPrice(retailerName: "Levi's Store", price: 249.00, shippingCost: 10, deliveryDays: 3),
                    RetailerPrice(retailerName: "Zara", price: 269.00, shippingCost: 15, deliveryDays: 4),
                    RetailerPrice(retailerName: "H&M", price: 239.00, shippingCost: 10, deliveryDays: 3)
                ],
                averageRating: 4.7,
                reviewCount: 234,
                specifications: ["Размеры": "28-38", "Цвета": "Синий, Черный", "Крой": "Прямой"]
            ),
            Product(
                name: "IKEA MALM Комод",
                description: "Функциональный комод с 6 ящиками, идеально подходит для спальни или гостиной.",
                category: .home,
                prices: [
                    RetailerPrice(retailerName: "IKEA", price: 349.00, shippingCost: 30, deliveryDays: 5),
                    RetailerPrice(retailerName: "Мебель Центр", price: 389.00, shippingCost: 0, deliveryDays: 3)
                ],
                averageRating: 4.5,
                reviewCount: 421,
                specifications: ["Размеры": "80x123 см", "Материал": "ДСП", "Цвета": "Белый, Черный-коричневый"]
            ),
            Product(
                name: "L'Oréal Revitalift Крем",
                description: "Антивозрастной дневной крем с ретинолом и гиалуроновой кислотой для упругости кожи.",
                category: .beauty,
                prices: [
                    RetailerPrice(retailerName: "Подружка", price: 45.00, shippingCost: 5, deliveryDays: 2),
                    RetailerPrice(retailerName: "Рив Гош", price: 49.00, shippingCost: 0, deliveryDays: 2),
                    RetailerPrice(retailerName: "Медовея", price: 47.00, shippingCost: 5, deliveryDays: 3)
                ],
                averageRating: 4.4,
                reviewCount: 892,
                specifications: ["Объем": "50ml", "SPF": "15", "Тип кожи": "Все типы"],
                isDeal: true,
                dealExpiryDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
                dealDiscount: 25
            ),
            Product(
                name: "Apple MacBook Air M2",
                description: "Ультратонкий ноутбук с революционным чипом M2, 13.6\" Liquid Retina дисплеем и до 18 часов работы.",
                category: .electronics,
                prices: [
                    RetailerPrice(retailerName: "iStore", price: 3499.00, shippingCost: 0, deliveryDays: 1),
                    RetailerPrice(retailerName: "TechnoMart", price: 3599.00, shippingCost: 20, deliveryDays: 2),
                    RetailerPrice(retailerName: "5 Element", price: 3650.00, shippingCost: 15, deliveryDays: 3)
                ],
                averageRating: 4.9,
                reviewCount: 445,
                specifications: ["Процессор": "Apple M2", "Память": "8GB RAM + 256GB SSD", "Экран": "13.6\" Retina"]
            )
        ]
        
        products = sampleProducts
        saveProducts()
    }
    
    // MARK: - Reset
    
    func resetAllData() {
        products.removeAll()
        wishlistItems.removeAll()
        UserDefaults.standard.removeObject(forKey: productsKey)
        UserDefaults.standard.removeObject(forKey: wishlistKey)
        generateSampleDataIfNeeded()
    }
}

