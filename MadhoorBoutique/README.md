# 🛍️ Madhoor Boutique — iOS App

A full-featured SwiftUI e-commerce app for Madhoor Boutique, supporting product browsing, search, buying, renting, cart, checkout, and user profile management.

---

## 📁 Project Structure

```
MadhoorBoutique/
├── MadhoorBoutiqueApp.swift          # App entry point
│
├── Models/
│   └── Models.swift                  # All data models
│       - Product, ProductCategory
│       - AppUser, ShippingAddress
│       - CartItem, Order
│       - ServiceType, PaymentMethod, OrderStatus
│
├── ViewModels/
│   └── ViewModels.swift              # Business logic
│       - AuthViewModel               # Login / Register / User session
│       - ProductsViewModel           # Product list, search, filter, sort
│       - CartViewModel               # Cart items, totals, CRUD
│
├── Views/
│   ├── ContentView.swift             # Root view + Tab navigation
│   │
│   ├── Auth/
│   │   └── AuthViews.swift           # WelcomeView, LoginView, RegisterView
│   │
│   ├── Home/
│   │   └── HomeView.swift            # Home tab: banners, categories, featured products
│   │
│   ├── Shop/
│   │   ├── ShopView.swift            # Product grid with search + filter + sort
│   │   └── ProductDetailView.swift   # Full product page: size, color, rent/buy, cart
│   │
│   ├── Cart/
│   │   └── CartView.swift            # Cart items, quantity, price summary
│   │
│   ├── Checkout/
│   │   └── CheckoutView.swift        # 3-step checkout: address → payment → review
│   │
│   └── Profile/
│       └── ProfileView.swift         # User profile, addresses, orders, logout
│
└── Helpers/
    └── Extensions.swift              # Color(hex:), currency & date formatters
```

---

## ✅ Features Implemented

### 🛒 Products & Categories
- **8 Categories**: Female Suites, Blouse Designs, Sports Wear, Track Suits, Sports T-Shirts, Shorts, Sarees, Bridal Lehenga
- **16 Sample Products** with names, descriptions, prices, sizes, colors, ratings
- Search by name, description, or category
- Filter by category
- Sort by: Featured, Price Low-High, Price High-Low, Top Rated, Newest

### 🛍️ Buy & Rent Services
- Each product can support **Buy**, **Rent**, or both
- Rental price per day shown separately
- Rental period selection (start & end date)
- Dynamic pricing calculation based on rental days × quantity

### 🛒 Cart
- Add items with selected size, color, service type, quantity
- Inline quantity adjustment (swipe to delete)
- Total calculation with free delivery above ₹999
- Cart badge on tab bar

### 💳 Checkout (3 Steps)
1. **Address Selection** — choose saved address or add new
2. **Payment Method**:
   - UPI (UPI ID input)
   - Credit Card (card number, expiry, CVV, name)
   - Debit Card
   - Cash on Delivery
3. **Order Review** — items, address, payment, total
4. **Order Success** screen after placing

### 👤 User Authentication
- Welcome screen with Sign In / Create Account
- Register with: Full Name, Email, Mobile, Password
- Login (simulated session)
- Logout

### 📦 Orders
- Order history with status badges (Placed → Confirmed → Shipped → Delivered)
- Order detail view per order
- Payment method shown on each order

### 📍 Address Management
- Add multiple addresses (Home / Work / Other)
- Select default delivery address during checkout
- Saved in user profile

### 👤 Profile
- User avatar with initials
- Order count, address count, rental count stats
- View/manage saved addresses
- Sign out

---

## 🚀 Setup Instructions

### Requirements
- Xcode 15+ 
- iOS 17+ target
- Swift 5.9+

### Steps
1. Open Xcode → **File → New → Project → App**
2. Set:
   - Product Name: `MadhoorBoutique`
   - Interface: `SwiftUI`
   - Language: `Swift`
3. **Delete** the auto-generated `ContentView.swift`
4. Copy all `.swift` files from this package into the project, preserving the folder structure (create Groups in Xcode)
5. Make sure `MadhoorBoutiqueApp.swift` is the app entry point
6. Build & Run on iOS Simulator (iPhone 15 recommended)

### No External Dependencies Required
All UI is built with pure SwiftUI + SF Symbols. No CocoaPods or SPM packages needed.

---

## 🎨 Design System

| Element | Value |
|---------|-------|
| Primary Pink | `#E91E8C` |
| Deep Purple | `#4A0E5E` |
| Background | `#FAF5FF` |
| Text Dark | `#1A0533` |
| Font (Headings) | Georgia Bold Italic |
| Font (Body) | SF Pro (system) |

---

## 🔮 Future Enhancements

- Firebase Authentication + Firestore for real backend
- Real product images (Firebase Storage / Cloudinary)
- Razorpay / UPI SDK for actual payments
- Push notifications for order status
- Wishlist / Favourites feature
- Product reviews & ratings submission
- Admin panel for inventory management
- Nearby store locator (MapKit)
- WhatsApp Business API for order updates
- Size guide with measurement charts
