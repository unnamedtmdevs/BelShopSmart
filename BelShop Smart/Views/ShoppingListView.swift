//
//  ShoppingListView.swift
//  BelShop Smart
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @State private var showingSortOptions = false
    @State private var selectedProduct: Product?
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                if viewModel.wishlistProducts.isEmpty {
                    emptyState
                } else {
                    productList
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
                Text("Wishlist")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingSortOptions = true }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 20))
                        .foregroundColor(Color("AccentBlue"))
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .actionSheet(isPresented: $showingSortOptions) {
                    ActionSheet(
                        title: Text("Sort By"),
                        buttons: ShoppingListViewModel.SortOption.allCases.map { option in
                            .default(Text(option.rawValue)) {
                                viewModel.sortOption = option
                                viewModel.loadWishlist()
                            }
                        } + [.cancel(Text("Cancel"))]
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            searchBar
            categoryFilter
        }
        .background(Color("BackgroundPrimary"))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Search products...", text: $viewModel.searchText)
                .foregroundColor(.white)
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.loadWishlist()
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
                    viewModel.loadWishlist()
                }
                
                ForEach(ProductCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: category.iconName,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                        viewModel.loadWishlist()
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    private var productList: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(viewModel.wishlistProducts) { product in
                    WishlistProductCard(product: product) {
                        selectedProduct = product
                    } onRemove: {
                        withAnimation {
                            viewModel.removeFromWishlist(product)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Your Wishlist is Empty")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Add products from the\nDeals tab or search")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

struct WishlistProductCard: View {
    let product: Product
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                productImage
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(product.category.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 8) {
                        Text(String(format: "%.2f BYN", product.lowestPrice))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("AccentYellow"))
                        
                        if product.priceSavings > 0 {
                            Text("↓ \(String(format: "%.2f", product.priceSavings))")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                    
                    if product.isDeal {
                        HStack(spacing: 5) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                            Text("Deal -\(product.dealDiscount ?? 0)%")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(Color("AccentYellow"))
                    }
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color("AccentBlue"))
                        .padding(8)
                }
            }
            .padding()
            .background(Color("BackgroundSecondary"))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var productImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .frame(width: 80, height: 80)
            
            Image(systemName: product.category.iconName)
                .font(.system(size: 35))
                .foregroundColor(Color("AccentBlue"))
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                    Color("AccentBlue") :
                    Color.white.opacity(0.1)
            )
            .cornerRadius(20)
        }
    }
}

