import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedSize: String = ""
    @State private var selectedColor: String = ""
    @State private var serviceType: ServiceType = .buy
    @State private var quantity: Int = 1
    @State private var rentalStart: Date = Date()
    @State private var rentalEnd: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
    @State private var showAddedToCart = false
    @State private var showDatePicker = false

    var rentalDays: Int {
        max(1, Calendar.current.dateComponents([.day], from: rentalStart, to: rentalEnd).day ?? 1)
    }

    var totalPrice: Double {
        if serviceType == .rent, let daily = product.rentalPricePerDay {
            return daily * Double(rentalDays) * Double(quantity)
        }
        return product.price * Double(quantity)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Product image
                        productImageSection

                        VStack(alignment: .leading, spacing: 20) {
                            // Title & Rating
                            productInfoHeader

                            Divider()

                            // Service type toggle (Buy / Rent)
                            if product.isAvailableForRent && product.isAvailableForBuy {
                                serviceTypeToggle
                            }

                            // Rental dates if rent
                            if serviceType == .rent {
                                rentalDateSection
                            }

                            // Size selector
                            if !product.sizes.isEmpty {
                                sizeSelector
                            }

                            // Color selector
                            if !product.colors.isEmpty {
                                colorSelector
                            }

                            // Quantity
                            quantitySelector

                            // Pricing summary
                            pricingSummary

                            Spacer(minLength: 100)
                        }
                        .padding(20)
                    }
                }

                // Bottom Add to Cart bar
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Text("₹\(Int(totalPrice))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "#E91E8C"))
                        }
                        Spacer()
                        Button {
                            addToCart()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: showAddedToCart ? "checkmark" : "cart.badge.plus")
                                Text(showAddedToCart ? "Added!" : "Add to Cart")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                showAddedToCart
                                ? LinearGradient(colors: [Color.green, Color.green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                        }
                        .disabled(selectedSize.isEmpty || selectedColor.isEmpty)
                        .opacity(selectedSize.isEmpty || selectedColor.isEmpty ? 0.6 : 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.white)
                }
            }
            .navigationBarItems(
                leading: Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(hex: "#1A0533"))
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            selectedSize = product.sizes.first ?? ""
            selectedColor = product.colors.first ?? ""
        }
    }

    // MARK: - Sub Views

    var productImageSection: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: product.category.color).opacity(0.25),
                         Color(hex: product.category.color).opacity(0.05)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(height: 300)

            Image(systemName: product.category.icon)
                .font(.system(size: 80))
                .foregroundColor(Color(hex: product.category.color).opacity(0.3))
        }
        .frame(height: 300)
    }

    var productInfoHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.category.rawValue.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: product.category.color))
                .kerning(1)

            Text(product.name)
                .font(.custom("Georgia-Bold", size: 22))
                .foregroundColor(Color(hex: "#1A0533"))

            HStack(spacing: 4) {
                ForEach(0..<5) { star in
                    Image(systemName: Double(star) < product.rating ? "star.fill" : "star")
                        .font(.system(size: 13))
                        .foregroundColor(.orange)
                }
                Text("(\(product.reviewCount) reviews)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Text(product.description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var serviceTypeToggle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Service Type")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            HStack(spacing: 0) {
                ForEach(ServiceType.allCases, id: \.self) { type in
                    Button {
                        serviceType = type
                    } label: {
                        VStack(spacing: 3) {
                            Text(type.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(serviceType == type ? .white : Color(hex: "#4A0E5E"))
                            if type == .rent, let daily = product.rentalPricePerDay {
                                Text("₹\(Int(daily))/day")
                                    .font(.system(size: 10))
                                    .foregroundColor(serviceType == type ? .white.opacity(0.8) : .gray)
                            } else {
                                Text("₹\(Int(product.price))")
                                    .font(.system(size: 10))
                                    .foregroundColor(serviceType == type ? .white.opacity(0.8) : .gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(serviceType == type
                            ? LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .leading, endPoint: .trailing))
                    }
                }
            }
            .background(Color(hex: "#F0E6FF"))
            .cornerRadius(12)
        }
    }

    var rentalDateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rental Period — \(rentalDays) day\(rentalDays > 1 ? "s" : "")")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            HStack(spacing: 12) {
                dateBox(label: "Start Date", date: $rentalStart)
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                dateBox(label: "End Date", date: $rentalEnd)
            }
        }
    }

    func dateBox(label: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 11)).foregroundColor(.gray)
            DatePicker("", selection: date, in: Date()..., displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 3)
        }
    }

    var sizeSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Size: \(selectedSize)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(product.sizes, id: \.self) { size in
                        Button {
                            selectedSize = size
                        } label: {
                            Text(size)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(selectedSize == size ? .white : Color(hex: "#4A0E5E"))
                                .frame(minWidth: 46, minHeight: 36)
                                .padding(.horizontal, 6)
                                .background(
                                    selectedSize == size
                                    ? LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color.white, Color.white], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#9C27B0").opacity(0.3), lineWidth: 1))
                        }
                    }
                }
            }
        }
    }

    var colorSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Color: \(selectedColor)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(product.colors, id: \.self) { color in
                        Button {
                            selectedColor = color
                        } label: {
                            Text(color)
                                .font(.system(size: 12))
                                .foregroundColor(selectedColor == color ? Color(hex: "#E91E8C") : Color(hex: "#4A0E5E"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedColor == color ? Color(hex: "#FFE4F2") : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(
                                    selectedColor == color ? Color(hex: "#E91E8C") : Color.gray.opacity(0.2),
                                    lineWidth: selectedColor == color ? 1.5 : 1))
                        }
                    }
                }
            }
        }
    }

    var quantitySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quantity")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            HStack(spacing: 16) {
                Button {
                    if quantity > 1 { quantity -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .foregroundColor(Color(hex: "#9C27B0"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#F0E6FF"))
                        .cornerRadius(8)
                }

                Text("\(quantity)")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 32, alignment: .center)

                Button {
                    if quantity < product.stockQuantity { quantity += 1 }
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color(hex: "#9C27B0"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#F0E6FF"))
                        .cornerRadius(8)
                }

                Spacer()
                Text("\(product.stockQuantity) in stock")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }

    var pricingSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Summary")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            VStack(spacing: 8) {
                if serviceType == .rent, let daily = product.rentalPricePerDay {
                    priceRow(label: "Rental Rate", value: "₹\(Int(daily))/day")
                    priceRow(label: "Days", value: "\(rentalDays) days")
                    priceRow(label: "Quantity", value: "× \(quantity)")
                } else {
                    priceRow(label: "Unit Price", value: "₹\(Int(product.price))")
                    priceRow(label: "Quantity", value: "× \(quantity)")
                }
                Divider()
                HStack {
                    Text("Total")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("₹\(Int(totalPrice))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#E91E8C"))
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 4)
        }
    }

    func priceRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundColor(.gray)
            Spacer()
            Text(value).font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "#1A0533"))
        }
    }

    // MARK: - Add to Cart
    func addToCart() {
        let item = CartItem(
            product: product,
            quantity: quantity,
            selectedSize: selectedSize,
            selectedColor: selectedColor,
            serviceType: serviceType,
            rentalStartDate: serviceType == .rent ? rentalStart : nil,
            rentalEndDate: serviceType == .rent ? rentalEnd : nil
        )
        cartVM.addItem(item)
        withAnimation {
            showAddedToCart = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showAddedToCart = false
        }
    }
}
