//
//  UserModel.swift
//  BelShop Smart
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var email: String
    var preferences: UserPreferences
    var favoriteCategories: [ProductCategory]
    var notificationSettings: NotificationSettings
    var createdDate: Date
    
    init(id: UUID = UUID(),
         username: String,
         email: String,
         preferences: UserPreferences = UserPreferences(),
         favoriteCategories: [ProductCategory] = [],
         notificationSettings: NotificationSettings = NotificationSettings(),
         createdDate: Date = Date()) {
        self.id = id
        self.username = username
        self.email = email
        self.preferences = preferences
        self.favoriteCategories = favoriteCategories
        self.notificationSettings = notificationSettings
        self.createdDate = createdDate
    }
}

struct UserPreferences: Codable {
    var currency: String
    var language: String
    var darkModeEnabled: Bool
    var maxShippingCost: Double?
    var preferredRetailers: [String]
    
    init(currency: String = "BYN",
         language: String = "ru",
         darkModeEnabled: Bool = false,
         maxShippingCost: Double? = nil,
         preferredRetailers: [String] = []) {
        self.currency = currency
        self.language = language
        self.darkModeEnabled = darkModeEnabled
        self.maxShippingCost = maxShippingCost
        self.preferredRetailers = preferredRetailers
    }
}

struct NotificationSettings: Codable {
    var dealAlertsEnabled: Bool
    var priceDropAlertsEnabled: Bool
    var wishlistUpdatesEnabled: Bool
    var weeklyDigestEnabled: Bool
    
    init(dealAlertsEnabled: Bool = true,
         priceDropAlertsEnabled: Bool = true,
         wishlistUpdatesEnabled: Bool = true,
         weeklyDigestEnabled: Bool = false) {
        self.dealAlertsEnabled = dealAlertsEnabled
        self.priceDropAlertsEnabled = priceDropAlertsEnabled
        self.wishlistUpdatesEnabled = wishlistUpdatesEnabled
        self.weeklyDigestEnabled = weeklyDigestEnabled
    }
}

