//
//  AuthenticationService.swift
//  BelShop Smart
//

import Foundation
import Combine

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated: Bool = false
    
    private let userKey = "current_user"
    
    private init() {
        loadUser()
    }
    
    // MARK: - User Loading & Saving
    
    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let decoded = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = decoded
            isAuthenticated = true
        }
    }
    
    private func saveUser() {
        if let user = currentUser,
           let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    // MARK: - Authentication
    
    func createUser(username: String, email: String, favoriteCategories: [ProductCategory] = []) {
        let user = User(
            username: username,
            email: email,
            favoriteCategories: favoriteCategories
        )
        currentUser = user
        isAuthenticated = true
        saveUser()
    }
    
    func updateUser(_ user: User) {
        currentUser = user
        saveUser()
    }
    
    func updatePreferences(_ preferences: UserPreferences) {
        guard var user = currentUser else { return }
        user.preferences = preferences
        currentUser = user
        saveUser()
    }
    
    func updateNotificationSettings(_ settings: NotificationSettings) {
        guard var user = currentUser else { return }
        user.notificationSettings = settings
        currentUser = user
        saveUser()
    }
    
    func addFavoriteCategory(_ category: ProductCategory) {
        guard var user = currentUser else { return }
        if !user.favoriteCategories.contains(category) {
            user.favoriteCategories.append(category)
            currentUser = user
            saveUser()
        }
    }
    
    func removeFavoriteCategory(_ category: ProductCategory) {
        guard var user = currentUser else { return }
        user.favoriteCategories.removeAll { $0 == category }
        currentUser = user
        saveUser()
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    func resetAccount() {
        logout()
        DataService.shared.resetAllData()
    }
}

