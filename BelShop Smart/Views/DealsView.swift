//
//  DealsView.swift
//  BelShop Smart
//

import SwiftUI

struct DealsView: View {
    @StateObject private var viewModel = DealsViewModel()
    @State private var selectedProduct: Product?
    @State private var showingFilters = false
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                if viewModel.deals.isEmpty {
                    emptyState
                } else {
                    dealsList
                }
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
        }
    }
    
    private var header: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Deals & Offers")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.deals.count) active deals")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("AccentYellow"))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            searchBar
            categoryFilter
            
            if !viewModel.getExpiringDeals().isEmpty {
                expiringDealsSection
            }
        }
        .background(Color("BackgroundPrimary"))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Search deals...", text: $viewModel.searchText)
                .foregroundColor(.white)
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.loadDeals()
                }
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                    viewModel.loadDeals()
                }
                
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: category.iconName,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                        viewModel.loadDeals()
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    private var expiringDealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color("AccentYellow"))
                Text("Expiring Soon")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.getExpiringDeals().prefix(5)) { product in
                        ExpiringDealCard(
                            product: product,
                            timeRemaining: viewModel.timeRemaining(for: product)
                        ) {
                            selectedProduct = product
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var dealsList: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(viewModel.getDealsByDiscount()) { product in
                    DealProductCard(
                        product: product,
                        timeRemaining: viewModel.timeRemaining(for: product)
                    ) {
                        selectedProduct = product
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "flame.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Active Deals")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Check back later for\nnew amazing offers")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

struct DealProductCard: View {
    let product: Product
    let timeRemaining: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    productImage
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("-\(product.dealDiscount ?? 0)%")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    LinearGradient(
                                        colors: [Color.red, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                            
                            Text(product.category.rawValue)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Text(product.name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(String(format: "%.2f", product.lowestPrice))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("AccentYellow"))
                            
                            Text("BYN")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("AccentYellow").opacity(0.8))
                            
                            if product.highestPrice > product.lowestPrice {
                                Text(String(format: "%.2f", product.highestPrice))
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                                    .strikethrough()
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color("AccentYellow"))
                            Text(String(format: "%.1f", product.averageRating))
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                            Text("(\(product.reviewCount))")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color("AccentYellow"))
                    
                    Text(timeRemaining)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(product.prices.count) stores")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.05))
            }
            .background(Color("BackgroundSecondary"))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var productImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color("AccentBlue").opacity(0.3), Color("AccentYellow").opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 90)
            
            Image(systemName: product.category.iconName)
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
}

struct ExpiringDealCard: View {
    let product: Product
    let timeRemaining: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("AccentBlue").opacity(0.2))
                        .frame(width: 140, height: 100)
                    
                    Image(systemName: product.category.iconName)
                        .font(.system(size: 50))
                        .foregroundColor(Color("AccentBlue"))
                        .frame(width: 140, height: 100)
                    
                    Text("-\(product.dealDiscount ?? 0)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                        .padding(8)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(product.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .frame(width: 140, alignment: .leading)
                    
                    Text(String(format: "%.2f BYN", product.lowestPrice))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("AccentYellow"))
                    
                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text(timeRemaining)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.red.opacity(0.8))
                }
            }
            .frame(width: 140)
            .padding()
            .background(Color("BackgroundSecondary"))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

