//
//  ContentView.swift
//  BelShop Smart
//
//  Created by Simon Bakhanets on 31.12.2025.
//

//
//  ContentView.swift
//  BelShop Smart
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else {
            mainTabView
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            DealsView()
                .tabItem {
                    Label("Акции", systemImage: "flame.fill")
                }
                .tag(0)
            
            ShoppingListView()
                .tabItem {
                    Label("Желания", systemImage: "heart.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .accentColor(Color("AccentYellow"))
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(Color("BackgroundSecondary"))
            appearance.shadowColor = .clear
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
