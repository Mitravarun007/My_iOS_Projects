import SwiftUI

struct HomeView: View {
    @EnvironmentObject var productsVM: ProductsViewModel
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedProduct: Product?
    @State private var showSearch = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        homeHeader

                        // Search Bar
                        NavigationLink(destination: ShopView(), isActive: $showSearch) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text("Search sarees, lehengas, suits...")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.gray.opacity(0.8))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(.plain)

                        // Banner Carousel
                        bannerSection

                        // Categories
                        categorySection

                        // Featured Products
                        productsSection(title: "✨ Featured Collection",
                                        products: productsVM.featuredProducts)

                        // Rental Products
                        productsSection(title: "🎀 Available for Rent",
                                        products: productsVM.rentalProducts)

                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
                .environmentObject(cartVM)
                .environmentObject(authVM)
        }
    }

    // MARK: - Header
    var homeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Hello, \(authVM.currentUser?.fullName.components(separatedBy: " ").first ?? "Guest") 👋")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("Madhoor Boutique")
                    .font(.custom("Georgia-BoldItalic", size: 22))
                    .foregroundColor(Color(hex: "#1A0533"))
            }
            Spacer()
            ZStack(alignment: .topTrailing) {
                NavigationLink(destination: CartView().environmentObject(cartVM).environmentObject(authVM)) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "#E91E8C"))
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                if cartVM.itemCount > 0 {
                    Text("\(cartVM.itemCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 2, y: -2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: - Banner
    var bannerSection: some View {
        TabView {
            ForEach(bannerItems, id: \.title) { item in
                ZStack {
                    LinearGradient(colors: item.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.tag)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                        Text(item.title)
                            .font(.custom("Georgia-Bold", size: 22))
                            .foregroundColor(.white)
                        Text(item.subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                        Text(item.cta)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .cornerRadius(16)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 160)
        .padding(.horizontal, 20)
    }

    struct BannerItem {
        let tag, title, subtitle, cta: String
        let colors: [Color]
    }

    var bannerItems: [BannerItem] = [
        BannerItem(tag: "NEW ARRIVAL", title: "Bridal Lehengas 2025", subtitle: "Exquisite collection for your special day", cta: "Explore Now",
                   colors: [Color(hex: "#4A0E5E"), Color(hex: "#E91E8C")]),
        BannerItem(tag: "RENT & SAVE", title: "Rent Premium Sarees", subtitle: "Up to 80% savings on rentals", cta: "Rent Now",
                   colors: [Color(hex: "#B71C1C"), Color(hex: "#F44336")]),
        BannerItem(tag: "SPORTS COLLECTION", title: "Active Wear Range", subtitle: "Style meets performance", cta: "Shop Now",
                   colors: [Color(hex: "#1565C0"), Color(hex: "#42A5F5")]),
    ]

    // MARK: - Categories
    var categorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Shop by Category")
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ProductCategory.allCases) { category in
                        CategoryChip(category: category, isSelected: productsVM.selectedCategory == category) {
                            if productsVM.selectedCategory == category {
                                productsVM.selectedCategory = nil
                            } else {
                                productsVM.selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Products Section
    func productsSection(title: String, products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: title)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(products) { product in
                        ProductCard(product: product)
                            .onTapGesture { selectedProduct = product }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: ProductCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: category.color) : Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.08), radius: 4)
                    Image(systemName: category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : Color(hex: category.color))
                }
                Text(category.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: category.color) : Color.gray)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
                    .lineLimit(2)
            }
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    @EnvironmentObject var cartVM: CartViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(LinearGradient(
                        colors: [Color(hex: product.category.color).opacity(0.2),
                                 Color(hex: product.category.color).opacity(0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 160, height: 180)
                    .overlay(
                        Image(systemName: product.category.icon)
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: product.category.color).opacity(0.4))
                    )

                VStack(spacing: 4) {
                    if product.isAvailableForRent {
                        Text("RENT")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: "#E91E8C"))
                            .cornerRadius(4)
                    }
                }
                .padding(8)
            }
            .frame(width: 160, height: 180)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A0533"))
                    .lineLimit(2)

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", product.rating))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text("(\(product.reviewCount))")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }

                Text("₹\(Int(product.price))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#E91E8C"))

                if let rental = product.rentalPricePerDay {
                    Text("Rent ₹\(Int(rental))/day")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .padding(10)
        }
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
        .frame(width: 160)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#E91E8C"))
            }
        }
    }
}
