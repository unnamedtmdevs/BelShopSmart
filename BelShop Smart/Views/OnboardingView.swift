//
//  OnboardingView.swift
//  BelShop Smart
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var username = ""
    @State private var email = ""
    @State private var selectedCategories: Set<ProductCategory> = []
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if currentPage < pages.count {
                    featurePages
                } else {
                    setupPage
                }
                
                bottomControls
            }
        }
    }
    
    private var featurePages: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: pages[currentPage].icon)
                .font(.system(size: 100))
                .foregroundColor(Color("AccentBlue"))
                .padding(.bottom, 20)
            
            Text(pages[currentPage].title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(pages[currentPage].description)
                .font(.system(size: 18, weight: .regular, design: .default))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            
            Spacer()
        }
    }
    
    private var setupPage: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Set Up Your Profile")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Username")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    TextField("Enter your name", text: $username)
                        .textFieldStyle(OnboardingTextFieldStyle())
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Email (Optional)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    TextField("example@email.com", text: $email)
                        .textFieldStyle(OnboardingTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Favorite Categories")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategories.contains(category)
                            ) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private var bottomControls: some View {
        VStack(spacing: 20) {
            pageIndicator
            
            HStack(spacing: 15) {
                if currentPage > 0 {
                    Button(action: previousPage) {
                        Text("Back")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(16)
                    }
                }
                
                Button(action: nextPage) {
                    Text(currentPage == pages.count ? "Get Started" : "Next")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color("AccentBlue"), Color("AccentYellow")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .disabled(currentPage == pages.count && username.isEmpty)
                .opacity(currentPage == pages.count && username.isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0...pages.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color("AccentYellow") : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.easeInOut, value: currentPage)
            }
        }
        .padding(.bottom, 10)
    }
    
    private func nextPage() {
        if currentPage < pages.count {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func previousPage() {
        withAnimation {
            currentPage = max(0, currentPage - 1)
        }
    }
    
    private func completeOnboarding() {
        let categories = Array(selectedCategories)
        AuthenticationService.shared.createUser(
            username: username.isEmpty ? "User" : username,
            email: email,
            favoriteCategories: categories
        )
        hasCompletedOnboarding = true
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    
    static let allPages = [
        OnboardingPage(
            title: "Compare Prices",
            description: "Find the best deals across multiple stores and save money",
            icon: "chart.bar.fill"
        ),
        OnboardingPage(
            title: "Create Wishlists",
            description: "Save your favorite products and track price changes",
            icon: "heart.fill"
        ),
        OnboardingPage(
            title: "Get Notifications",
            description: "Stay updated on new deals and discounts for products you love",
            icon: "bell.badge.fill"
        )
    ]
}

struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
            .font(.system(size: 16))
    }
}

struct CategoryButton: View {
    let category: ProductCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.iconName)
                    .font(.system(size: 20))
                Text(category.rawValue)
                    .font(.system(size: 15, weight: .medium))
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

