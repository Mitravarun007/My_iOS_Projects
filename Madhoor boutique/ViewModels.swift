import Foundation
import Combine

// MARK: - Auth ViewModel
class AuthViewModel: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Simulated user store (in production, use a backend/Firebase)
    private var registeredUsers: [AppUser] = []

    func register(fullName: String, email: String, mobile: String, password: String) {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.registeredUsers.contains(where: { $0.email == email }) {
                self.errorMessage = "An account with this email already exists."
                self.isLoading = false
                return
            }
            let newUser = AppUser(fullName: fullName, email: email, mobileNumber: mobile)
            self.registeredUsers.append(newUser)
            self.currentUser = newUser
            self.isLoggedIn = true
            self.isLoading = false
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let user = self.registeredUsers.first(where: { $0.email == email }) {
                self.currentUser = user
                self.isLoggedIn = true
            } else {
                // Demo: create a user on first login
                let demoUser = AppUser(fullName: "Demo User", email: email, mobileNumber: "9876543210")
                self.registeredUsers.append(demoUser)
                self.currentUser = demoUser
                self.isLoggedIn = true
            }
            self.isLoading = false
        }
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
    }

    func addAddress(_ address: ShippingAddress) {
        guard var user = currentUser else { return }
        user.addresses.append(address)
        if user.defaultAddressId == nil { user.defaultAddressId = address.id }
        currentUser = user
        updateUser(user)
    }

    func setDefaultAddress(_ id: UUID) {
        guard var user = currentUser else { return }
        user.defaultAddressId = id
        currentUser = user
        updateUser(user)
    }

    func addOrder(_ order: Order) {
        guard var user = currentUser else { return }
        user.orders.insert(order, at: 0)
        currentUser = user
        updateUser(user)
    }

    private func updateUser(_ user: AppUser) {
        if let idx = registeredUsers.firstIndex(where: { $0.id == user.id }) {
            registeredUsers[idx] = user
        }
    }
}

// MARK: - Products ViewModel
class ProductsViewModel: ObservableObject {
    @Published var products: [Product] = Product.sampleProducts
    @Published var searchText: String = ""
    @Published var selectedCategory: ProductCategory? = nil
    @Published var sortOption: SortOption = .featured

    enum SortOption: String, CaseIterable {
        case featured = "Featured"
        case priceLow = "Price: Low to High"
        case priceHigh = "Price: High to Low"
        case rating = "Top Rated"
        case newest = "Newest"
    }

    var filteredProducts: [Product] {
        var result = products

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .featured: break
        case .priceLow: result.sort { $0.price < $1.price }
        case .priceHigh: result.sort { $0.price > $1.price }
        case .rating: result.sort { $0.rating > $1.rating }
        case .newest: result.sort { $0.id.uuidString > $1.id.uuidString }
        }

        return result
    }

    var featuredProducts: [Product] {
        products.filter { $0.rating >= 4.7 }.prefix(6).map { $0 }
    }

    var rentalProducts: [Product] {
        products.filter { $0.isAvailableForRent }
    }
}

// MARK: - Cart ViewModel
class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []

    var totalAmount: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    func addItem(_ item: CartItem) {
        if let idx = items.firstIndex(where: {
            $0.product.id == item.product.id &&
            $0.selectedSize == item.selectedSize &&
            $0.selectedColor == item.selectedColor &&
            $0.serviceType == item.serviceType
        }) {
            items[idx].quantity += item.quantity
        } else {
            items.append(item)
        }
    }

    func removeItem(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func updateQuantity(_ item: CartItem, quantity: Int) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            if quantity <= 0 {
                items.remove(at: idx)
            } else {
                items[idx].quantity = quantity
            }
        }
    }

    func clearCart() {
        items = []
    }

    func isInCart(_ product: Product) -> Bool {
        items.contains { $0.product.id == product.id }
    }
}
