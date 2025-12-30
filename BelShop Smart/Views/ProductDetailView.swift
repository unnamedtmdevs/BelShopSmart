//
//  ProductDetailView.swift
//  BelShop Smart
//

import SwiftUI

struct ProductDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: ProductDetailViewModel
    @State private var showingAllSpecs = false
    
    init(product: Product) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        productHeader
                        priceComparison
                        productInfo
                        specifications
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
                
                VStack {
                    Spacer()
                    bottomBar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.toggleWishlist() }) {
                        Image(systemName: viewModel.isInWishlist ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isInWishlist ? Color("AccentYellow") : .white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
        }
    }
    
    private var productHeader: some View {
        VStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 200)
                
                Image(systemName: viewModel.product.category.iconName)
                    .font(.system(size: 80))
                    .foregroundColor(Color("AccentBlue"))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(viewModel.product.category.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("AccentBlue"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("AccentBlue").opacity(0.2))
                        .cornerRadius(8)
                    
                    if viewModel.product.isDeal {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                            Text("Акция -\(viewModel.product.dealDiscount ?? 0)%")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(Color("AccentYellow"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("AccentYellow").opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                
                Text(viewModel.product.name)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color("AccentYellow"))
                        Text(String(format: "%.1f", viewModel.product.averageRating))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("(\(viewModel.product.reviewCount) отзывов)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text(viewModel.product.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
                    .padding(.top, 5)
            }
        }
    }
    
    private var priceComparison: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Сравнение цен")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if viewModel.product.priceSavings > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Экономия")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        Text(String(format: "%.2f BYN", viewModel.product.priceSavings))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.sortedPrices) { retailerPrice in
                    RetailerPriceCard(
                        retailerPrice: retailerPrice,
                        isBestPrice: viewModel.isBestPrice(retailerPrice),
                        priceDifference: viewModel.getPriceDifference(from: retailerPrice)
                    )
                }
            }
        }
        .padding()
        .background(Color("BackgroundSecondary"))
        .cornerRadius(20)
    }
    
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Информация о товаре")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "tag.fill",
                    title: "Категория",
                    value: viewModel.product.category.rawValue
                )
                
                InfoRow(
                    icon: "cart.fill",
                    title: "Магазинов",
                    value: "\(viewModel.product.prices.count)"
                )
                
                InfoRow(
                    icon: "dollarsign.circle.fill",
                    title: "Цена от",
                    value: String(format: "%.2f BYN", viewModel.product.lowestPrice)
                )
                
                if let timeRemaining = viewModel.dealTimeRemaining {
                    InfoRow(
                        icon: "clock.fill",
                        title: "Акция до",
                        value: timeRemaining,
                        valueColor: Color("AccentYellow")
                    )
                }
            }
        }
        .padding()
        .background(Color("BackgroundSecondary"))
        .cornerRadius(20)
    }
    
    private var specifications: some View {
        Group {
            if !viewModel.product.specifications.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Характеристики")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 10) {
                        ForEach(Array(viewModel.product.specifications.keys.sorted()), id: \.self) { key in
                            HStack {
                                Text(key)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Spacer()
                                
                                Text(viewModel.product.specifications[key] ?? "")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 8)
                            
                            if key != viewModel.product.specifications.keys.sorted().last {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                            }
                        }
                    }
                }
                .padding()
                .background(Color("BackgroundSecondary"))
                .cornerRadius(20)
            }
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Лучшая цена")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(String(format: "%.2f BYN", viewModel.product.lowestPrice))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("AccentYellow"))
                }
                
                Spacer()
                
                if let bestRetailer = viewModel.product.bestRetailer {
                    Text(bestRetailer.retailerName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color("AccentBlue"), Color("AccentBlue").opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                }
            }
            .padding()
            .background(Color("BackgroundSecondary"))
        }
    }
}

struct RetailerPriceCard: View {
    let retailerPrice: RetailerPrice
    let isBestPrice: Bool
    let priceDifference: Double
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(retailerPrice.retailerName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if isBestPrice {
                        Text("ЛУЧШАЯ")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green)
                            .cornerRadius(6)
                    }
                }
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(retailerPrice.availability.color))
                        .frame(width: 8, height: 8)
                    
                    Text(retailerPrice.availability.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("• Доставка: \(retailerPrice.deliveryDays) дн.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f BYN", retailerPrice.totalPrice))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isBestPrice ? Color.green : .white)
                
                if !isBestPrice && priceDifference > 0 {
                    Text("+\(String(format: "%.2f", priceDifference))")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
                
                if retailerPrice.shippingCost > 0 {
                    Text("доставка: \(String(format: "%.2f", retailerPrice.shippingCost))")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding()
        .background(isBestPrice ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isBestPrice ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .white
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("AccentBlue"))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}

