import Foundation

// MARK: - Product Model
struct Product: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var price: Double
    var rentalPricePerDay: Double?
    var category: ProductCategory
    var images: [String]        // SF Symbol names or asset names
    var sizes: [String]
    var colors: [String]
    var isAvailableForRent: Bool
    var isAvailableForBuy: Bool
    var stockQuantity: Int
    var rating: Double
    var reviewCount: Int

    init(id: UUID = UUID(), name: String, description: String, price: Double,
         rentalPricePerDay: Double? = nil, category: ProductCategory,
         images: [String] = [], sizes: [String] = [], colors: [String] = [],
         isAvailableForRent: Bool = false, isAvailableForBuy: Bool = true,
         stockQuantity: Int = 10, rating: Double = 4.5, reviewCount: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.rentalPricePerDay = rentalPricePerDay
        self.category = category
        self.images = images
        self.sizes = sizes
        self.colors = colors
        self.isAvailableForRent = isAvailableForRent
        self.isAvailableForBuy = isAvailableForBuy
        self.stockQuantity = stockQuantity
        self.rating = rating
        self.reviewCount = reviewCount
    }
}

// MARK: - Product Category
enum ProductCategory: String, CaseIterable, Codable, Identifiable {
    case femaleSuites = "Female Suites"
    case blouseDesigns = "Blouse Designs"
    case sportsWear = "Sports Wear"
    case trackSuits = "Track Suits"
    case sportsTShirts = "Sports T-Shirts"
    case shorts = "Shorts"
    case sarees = "Sarees"
    case bridalLehenga = "Bridal Lehenga"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .femaleSuites: return "person.crop.rectangle"
        case .blouseDesigns: return "sparkles"
        case .sportsWear: return "figure.run"
        case .trackSuits: return "figure.walk"
        case .sportsTShirts: return "tshirt"
        case .shorts: return "figure.hiking"
        case .sarees: return "staroflife"
        case .bridalLehenga: return "crown"
        }
    }

    var color: String {
        switch self {
        case .femaleSuites: return "#E91E8C"
        case .blouseDesigns: return "#9C27B0"
        case .sportsWear: return "#FF5722"
        case .trackSuits: return "#2196F3"
        case .sportsTShirts: return "#4CAF50"
        case .shorts: return "#FF9800"
        case .sarees: return "#F44336"
        case .bridalLehenga: return "#FFD700"
        }
    }
}

// MARK: - User Model
struct AppUser: Identifiable, Codable {
    var id: UUID
    var fullName: String
    var email: String
    var mobileNumber: String
    var addresses: [ShippingAddress]
    var defaultAddressId: UUID?
    var profileImageName: String?
    var orders: [Order]

    init(id: UUID = UUID(), fullName: String, email: String,
         mobileNumber: String, addresses: [ShippingAddress] = [],
         defaultAddressId: UUID? = nil, orders: [Order] = []) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.mobileNumber = mobileNumber
        self.addresses = addresses
        self.defaultAddressId = defaultAddressId
        self.orders = orders
    }
}

// MARK: - Shipping Address
struct ShippingAddress: Identifiable, Codable, Hashable {
    var id: UUID
    var label: String         // Home, Work, Other
    var recipientName: String
    var streetAddress: String
    var city: String
    var state: String
    var pinCode: String
    var mobileNumber: String

    init(id: UUID = UUID(), label: String = "Home", recipientName: String,
         streetAddress: String, city: String, state: String,
         pinCode: String, mobileNumber: String) {
        self.id = id
        self.label = label
        self.recipientName = recipientName
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.pinCode = pinCode
        self.mobileNumber = mobileNumber
    }

    var fullAddress: String {
        "\(streetAddress), \(city), \(state) - \(pinCode)"
    }
}

// MARK: - Cart Item
struct CartItem: Identifiable, Codable {
    var id: UUID
    var product: Product
    var quantity: Int
    var selectedSize: String
    var selectedColor: String
    var serviceType: ServiceType
    var rentalStartDate: Date?
    var rentalEndDate: Date?

    init(id: UUID = UUID(), product: Product, quantity: Int = 1,
         selectedSize: String, selectedColor: String,
         serviceType: ServiceType = .buy,
         rentalStartDate: Date? = nil, rentalEndDate: Date? = nil) {
        self.id = id
        self.product = product
        self.quantity = quantity
        self.selectedSize = selectedSize
        self.selectedColor = selectedColor
        self.serviceType = serviceType
        self.rentalStartDate = rentalStartDate
        self.rentalEndDate = rentalEndDate
    }

    var totalPrice: Double {
        if serviceType == .rent,
           let start = rentalStartDate, let end = rentalEndDate,
           let dailyRate = product.rentalPricePerDay {
            let days = max(1, Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1)
            return dailyRate * Double(days) * Double(quantity)
        }
        return product.price * Double(quantity)
    }

    var rentalDays: Int {
        guard let start = rentalStartDate, let end = rentalEndDate else { return 0 }
        return max(1, Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1)
    }
}

// MARK: - Service Type
enum ServiceType: String, Codable, CaseIterable {
    case buy = "Buy"
    case rent = "Rent"
}

// MARK: - Order
struct Order: Identifiable, Codable {
    var id: UUID
    var items: [CartItem]
    var shippingAddress: ShippingAddress
    var paymentMethod: PaymentMethod
    var status: OrderStatus
    var orderDate: Date
    var totalAmount: Double

    init(id: UUID = UUID(), items: [CartItem], shippingAddress: ShippingAddress,
         paymentMethod: PaymentMethod, status: OrderStatus = .placed,
         orderDate: Date = Date(), totalAmount: Double) {
        self.id = id
        self.items = items
        self.shippingAddress = shippingAddress
        self.paymentMethod = paymentMethod
        self.status = status
        self.orderDate = orderDate
        self.totalAmount = totalAmount
    }
}

// MARK: - Order Status
enum OrderStatus: String, Codable, CaseIterable {
    case placed = "Placed"
    case confirmed = "Confirmed"
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    case returned = "Returned"

    var icon: String {
        switch self {
        case .placed: return "checkmark.circle"
        case .confirmed: return "checkmark.seal"
        case .processing: return "gear"
        case .shipped: return "shippingbox"
        case .delivered: return "house.circle"
        case .cancelled: return "xmark.circle"
        case .returned: return "arrow.uturn.left.circle"
        }
    }

    var color: String {
        switch self {
        case .placed, .confirmed: return "#2196F3"
        case .processing: return "#FF9800"
        case .shipped: return "#9C27B0"
        case .delivered: return "#4CAF50"
        case .cancelled, .returned: return "#F44336"
        }
    }
}

// MARK: - Payment Method
enum PaymentMethod: String, Codable, CaseIterable {
    case upi = "UPI"
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case cashOnDelivery = "Cash on Delivery"

    var icon: String {
        switch self {
        case .upi: return "indianrupeesign.circle"
        case .creditCard: return "creditcard"
        case .debitCard: return "creditcard.fill"
        case .cashOnDelivery: return "banknote"
        }
    }
}

// MARK: - Sample Data
extension Product {
    static let sampleProducts: [Product] = [
        Product(name: "Elegant Anarkali Suit", description: "Beautiful embroidered Anarkali suit with dupatta, perfect for festive occasions.", price: 2499, rentalPricePerDay: 299, category: .femaleSuites, images: ["suit1"], sizes: ["XS","S","M","L","XL","XXL"], colors: ["Rose Pink","Sky Blue","Mint Green"], isAvailableForRent: true, isAvailableForBuy: true, stockQuantity: 15, rating: 4.7, reviewCount: 128),
        Product(name: "Designer Salwar Kameez", description: "Cotton blend salwar kameez with intricate print design.", price: 1899, rentalPricePerDay: 199, category: .femaleSuites, images: ["suit2"], sizes: ["S","M","L","XL"], colors: ["Mustard","Teal","Coral"], isAvailableForRent: true, isAvailableForBuy: true, stockQuantity: 20, rating: 4.5, reviewCount: 95),
        Product(name: "Silk Embroidered Blouse", description: "Hand-embroidered silk blouse with mirror work, perfect for saree pairing.", price: 1299, rentalPricePerDay: 149, category: .blouseDesigns, images: ["blouse1"], sizes: ["XS","S","M","L","XL"], colors: ["Gold","Maroon","Navy"], isAvailableForRent: true, isAvailableForBuy: true, stockQuantity: 12, rating: 4.8, reviewCount: 74),
        Product(name: "Backless Designer Blouse", description: "Trendy backless blouse with cut-work detailing.", price: 999, category: .blouseDesigns, images: ["blouse2"], sizes: ["XS","S","M","L"], colors: ["Black","White","Red"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 18, rating: 4.6, reviewCount: 56),
        Product(name: "Women's Sports Track Suit", description: "Comfortable and stylish track suit for workouts and casual wear.", price: 1599, category: .trackSuits, images: ["track1"], sizes: ["S","M","L","XL","XXL"], colors: ["Black/Pink","Navy/White","Grey/Orange"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 25, rating: 4.4, reviewCount: 112),
        Product(name: "Running Track Suit Set", description: "Breathable polyester track suit with moisture-wicking technology.", price: 1899, category: .trackSuits, images: ["track2"], sizes: ["S","M","L","XL"], colors: ["All Black","Blue/Yellow"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 20, rating: 4.3, reviewCount: 88),
        Product(name: "Women's Sports T-Shirt", description: "Dry-fit round neck sports t-shirt with breathable fabric.", price: 599, category: .sportsTShirts, images: ["tshirt1"], sizes: ["XS","S","M","L","XL"], colors: ["White","Black","Pink","Blue"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 40, rating: 4.5, reviewCount: 200),
        Product(name: "Printed Sports Top", description: "Trendy printed sports top with comfortable stretch fabric.", price: 799, category: .sportsTShirts, images: ["tshirt2"], sizes: ["XS","S","M","L"], colors: ["Lavender","Coral","Lime"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 30, rating: 4.4, reviewCount: 145),
        Product(name: "Active Shorts", description: "Comfortable active shorts with drawstring waist for sports and gym.", price: 699, category: .shorts, images: ["shorts1"], sizes: ["XS","S","M","L","XL"], colors: ["Black","Navy","Grey"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 35, rating: 4.3, reviewCount: 167),
        Product(name: "Printed Cycling Shorts", description: "High-waist printed cycling shorts with compression support.", price: 899, category: .shorts, images: ["shorts2"], sizes: ["XS","S","M","L"], colors: ["Black/Floral","Blue/Geometric"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 22, rating: 4.5, reviewCount: 93),
        Product(name: "Pure Silk Kanjivaram Saree", description: "Authentic Kanjivaram silk saree with gold zari border — a timeless classic.", price: 12999, rentalPricePerDay: 999, category: .sarees, images: ["saree1"], sizes: ["Free Size"], colors: ["Ruby Red","Peacock Blue","Forest Green"], isAvailableForRent: true, isAvailableForBuy: true, stockQuantity: 8, rating: 4.9, reviewCount: 62),
        Product(name: "Designer Georgette Saree", description: "Lightweight georgette saree with digital print and sequin border.", price: 3499, rentalPricePerDay: 399, category: .sarees, images: ["saree2"], sizes: ["Free Size"], colors: ["Peach","Lilac","Turquoise"], isAvailableForRent: true, isAvailableForBuy: true, stockQuantity: 14, rating: 4.7, reviewCount: 89),
        Product(name: "Royal Bridal Lehenga", description: "Exquisite heavy embroidered bridal lehenga with dupatta and blouse. Perfect for wedding day.", price: 45999, rentalPricePerDay: 3999, category: .bridalLehenga, images: ["lehenga1"], sizes: ["XS","S","M","L","XL","XXL"], colors: ["Red/Gold","Pink/Silver","Maroon/Gold"], isAvailableForRent: true, isAvailableForBuy: true, stockQuantity: 5, rating: 5.0, reviewCount: 38),
        Product(name: "Pastel Bridal Lehenga", description: "Modern pastel-toned bridal lehenga with delicate threadwork and mirror embellishments.", price: 32999, rentalPricePerDay: 2999, category: .bridalLehenga, images: ["lehenga2"], sizes: ["XS","S","M","L","XL"], colors: ["Blush Pink","Powder Blue","Mint"], isAvailableForRent: true, isAvailableForBuy: true, stockQuantity: 6, rating: 4.9, reviewCount: 45),
        Product(name: "Sports Wear Set", description: "Complete sports wear set including top, shorts and jacket for active lifestyle.", price: 2199, category: .sportsWear, images: ["sports1"], sizes: ["S","M","L","XL"], colors: ["All Black","Navy Blue","Charcoal"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 18, rating: 4.4, reviewCount: 76),
        Product(name: "Yoga Wear Set", description: "Stretchable yoga set with crop top and high-waist leggings.", price: 1799, category: .sportsWear, images: ["sports2"], sizes: ["XS","S","M","L","XL"], colors: ["Purple","Teal","Rose"], isAvailableForRent: false, isAvailableForBuy: true, stockQuantity: 22, rating: 4.6, reviewCount: 134),
    ]
}
