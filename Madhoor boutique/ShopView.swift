import SwiftUI

struct ShopView: View {
    @EnvironmentObject var productsVM: ProductsViewModel
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedProduct: Product?
    @State private var showSortSheet = false
    @State private var showFilterSheet = false
    @FocusState private var searchFocused: Bool

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)

                    // Category filter row
                    categoryFilterRow

                    // Results count + sort
                    HStack {
                        Text("\(productsVM.filteredProducts.count) Products")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        Spacer()
                        Button {
                            showSortSheet = true
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 12))
                                Text(productsVM.sortOption.rawValue)
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(Color(hex: "#9C27B0"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#9C27B0").opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    // Product grid
                    if productsVM.filteredProducts.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No products found")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.gray)
                            Text("Try a different search or category")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(productsVM.filteredProducts) { product in
                                    ShopProductCard(product: product)
                                        .onTapGesture { selectedProduct = product }
                                        .environmentObject(cartVM)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CartView().environmentObject(cartVM).environmentObject(authVM)) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart.fill")
                                .foregroundColor(Color(hex: "#E91E8C"))
                            if cartVM.itemCount > 0 {
                                Text("\(cartVM.itemCount)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 14, height: 14)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
                .environmentObject(cartVM)
                .environmentObject(authVM)
        }
        .confirmationDialog("Sort By", isPresented: $showSortSheet, titleVisibility: .visible) {
            ForEach(ProductsViewModel.SortOption.allCases, id: \.self) { option in
                Button(option.rawValue) {
                    productsVM.sortOption = option
                }
            }
        }
    }

    var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search products...", text: $productsVM.searchText)
                .font(.system(size: 15))
                .focused($searchFocused)
                .autocorrectionDisabled()
            if !productsVM.searchText.isEmpty {
                Button {
                    productsVM.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(hex: "#F5F5F5"))
        .cornerRadius(12)
    }

    var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(title: "All", isSelected: productsVM.selectedCategory == nil) {
                    productsVM.selectedCategory = nil
                }
                ForEach(ProductCategory.allCases) { cat in
                    FilterPill(title: cat.rawValue, isSelected: productsVM.selectedCategory == cat) {
                        productsVM.selectedCategory = (productsVM.selectedCategory == cat) ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.white)
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : Color(hex: "#4A0E5E"))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color(hex: "#E91E8C") : Color(hex: "#F0E6FF"))
                .cornerRadius(20)
        }
    }
}

// MARK: - Shop Product Card (Grid style)
struct ShopProductCard: View {
    let product: Product
    @EnvironmentObject var cartVM: CartViewModel
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color(hex: product.category.color).opacity(0.2),
                                 Color(hex: product.category.color).opacity(0.07)],
                        startPoint: .top, endPoint: .bottom))
                    .frame(height: 170)
                    .overlay(
                        Image(systemName: product.category.icon)
                            .font(.system(size: 42))
                            .foregroundColor(Color(hex: product.category.color).opacity(0.35))
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
                    if product.stockQuantity < 5 {
                        Text("FEW LEFT")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
                .padding(8)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(product.category.rawValue)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: product.category.color))
                    .textCase(.uppercase)

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
                }

                HStack {
                    Text("₹\(Int(product.price))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#E91E8C"))
                    Spacer()
                    if cartVM.isInCart(product) {
                        Image(systemName: "cart.fill.badge.plus")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#9C27B0"))
                    } else {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#9C27B0"))
                    }
                }
            }
            .padding(10)
        }
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}
