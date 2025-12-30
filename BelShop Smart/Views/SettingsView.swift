//
//  SettingsView.swift
//  BelShop Smart
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var showingResetAlert = false
    @State private var showingLogoutAlert = false
    @State private var editingUsername = false
    @State private var newUsername = ""
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    profileSection
                    preferencesSection
                    notificationsSection
                    categoriesSection
                    accountSection
                    aboutSection
                }
                .padding()
            }
        }
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("Сбросить аккаунт?"),
                message: Text("Все данные будут удалены. Это действие нельзя отменить."),
                primaryButton: .destructive(Text("Сбросить")) {
                    authService.resetAccount()
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Настройки")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            
            if let user = authService.currentUser {
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color("AccentBlue"), Color("AccentYellow")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text(String(user.username.prefix(1)).uppercased())
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 5) {
                        if editingUsername {
                            HStack {
                                TextField("Новое имя", text: $newUsername)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: 200)
                                
                                Button("Сохранить") {
                                    if !newUsername.isEmpty {
                                        var updatedUser = user
                                        updatedUser.username = newUsername
                                        authService.updateUser(updatedUser)
                                        editingUsername = false
                                    }
                                }
                                .foregroundColor(Color("AccentBlue"))
                            }
                        } else {
                            HStack {
                                Text(user.username)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    newUsername = user.username
                                    editingUsername = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(Color("AccentBlue"))
                                }
                            }
                        }
                        
                        if !user.email.isEmpty {
                            Text(user.email)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Text("Участник с \(formatDate(user.createdDate))")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("BackgroundSecondary"))
                .cornerRadius(16)
            }
        }
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Настройки приложения")
            
            VStack(spacing: 0) {
                if let user = authService.currentUser {
                    SettingsToggle(
                        icon: "moon.fill",
                        title: "Темная тема",
                        isOn: Binding(
                            get: { user.preferences.darkModeEnabled },
                            set: { newValue in
                                var prefs = user.preferences
                                prefs.darkModeEnabled = newValue
                                authService.updatePreferences(prefs)
                            }
                        )
                    )
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                    
                    SettingsRow(
                        icon: "dollarsign.circle.fill",
                        title: "Валюта",
                        value: user.preferences.currency
                    )
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                    
                    SettingsRow(
                        icon: "globe",
                        title: "Язык",
                        value: "Русский"
                    )
                }
            }
            .background(Color("BackgroundSecondary"))
            .cornerRadius(16)
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Уведомления")
            
            VStack(spacing: 0) {
                if let user = authService.currentUser {
                    SettingsToggle(
                        icon: "flame.fill",
                        title: "Акции и предложения",
                        isOn: Binding(
                            get: { user.notificationSettings.dealAlertsEnabled },
                            set: { newValue in
                                var settings = user.notificationSettings
                                settings.dealAlertsEnabled = newValue
                                authService.updateNotificationSettings(settings)
                            }
                        )
                    )
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                    
                    SettingsToggle(
                        icon: "arrow.down.circle.fill",
                        title: "Снижение цен",
                        isOn: Binding(
                            get: { user.notificationSettings.priceDropAlertsEnabled },
                            set: { newValue in
                                var settings = user.notificationSettings
                                settings.priceDropAlertsEnabled = newValue
                                authService.updateNotificationSettings(settings)
                            }
                        )
                    )
                    
                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                    
                    SettingsToggle(
                        icon: "heart.fill",
                        title: "Обновления списка желаний",
                        isOn: Binding(
                            get: { user.notificationSettings.wishlistUpdatesEnabled },
                            set: { newValue in
                                var settings = user.notificationSettings
                                settings.wishlistUpdatesEnabled = newValue
                                authService.updateNotificationSettings(settings)
                            }
                        )
                    )
                }
            }
            .background(Color("BackgroundSecondary"))
            .cornerRadius(16)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Любимые категории")
            
            if let user = authService.currentUser {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        CategoryToggleButton(
                            category: category,
                            isSelected: user.favoriteCategories.contains(category)
                        ) {
                            if user.favoriteCategories.contains(category) {
                                authService.removeFavoriteCategory(category)
                            } else {
                                authService.addFavoriteCategory(category)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Аккаунт")
            
            VStack(spacing: 0) {
                Button(action: { showingResetAlert = true }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.orange)
                            .frame(width: 40)
                        
                        Text("Сбросить данные")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding()
                }
            }
            .background(Color("BackgroundSecondary"))
            .cornerRadius(16)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "О приложении")
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Версия",
                    value: "1.0.0"
                )
            }
            .background(Color("BackgroundSecondary"))
            .cornerRadius(16)
            
            Text("BelShopSmart - ваш умный помощник в покупках")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color("AccentBlue"))
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color("AccentBlue"))
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("AccentYellow"))
        }
        .padding()
    }
}

struct CategoryToggleButton: View {
    let category: ProductCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.iconName)
                    .font(.system(size: 18))
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isSelected ?
                    Color("AccentBlue") :
                    Color.white.opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("AccentYellow") : Color.clear, lineWidth: 2)
            )
        }
    }
}

