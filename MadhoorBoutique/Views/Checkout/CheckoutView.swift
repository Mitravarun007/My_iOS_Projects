import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var step: CheckoutStep = .address
    @State private var selectedAddressId: UUID?
    @State private var showAddAddress = false
    @State private var selectedPayment: PaymentMethod = .cashOnDelivery
    @State private var upiId: String = ""
    @State private var cardNumber: String = ""
    @State private var cardExpiry: String = ""
    @State private var cardCVV: String = ""
    @State private var cardHolderName: String = ""
    @State private var orderPlaced = false

    enum CheckoutStep: Int, CaseIterable {
        case address = 0
        case payment = 1
        case review = 2
    }

    var selectedAddress: ShippingAddress? {
        guard let id = selectedAddressId else {
            return authVM.currentUser?.addresses.first
        }
        return authVM.currentUser?.addresses.first { $0.id == id }
    }

    var canProceed: Bool {
        switch step {
        case .address: return selectedAddress != nil
        case .payment:
            switch selectedPayment {
            case .upi: return !upiId.isEmpty
            case .creditCard, .debitCard: return !cardNumber.isEmpty && !cardExpiry.isEmpty && !cardCVV.isEmpty
            case .cashOnDelivery: return true
            }
        case .review: return true
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                if orderPlaced {
                    orderSuccessView
                } else {
                    VStack(spacing: 0) {
                        // Step indicator
                        stepIndicator

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                switch step {
                                case .address: addressStep
                                case .payment: paymentStep
                                case .review: reviewStep
                                }
                            }
                            .padding(16)
                            .padding(.bottom, 100)
                        }

                        // Bottom action bar
                        actionBar
                    }
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") { dismiss() }
                .foregroundColor(Color(hex: "#9C27B0")))
        }
        .sheet(isPresented: $showAddAddress) {
            AddAddressView()
                .environmentObject(authVM)
        }
    }

    // MARK: - Step Indicator
    var stepIndicator: some View {
        HStack(spacing: 0) {
            ForEach(CheckoutStep.allCases, id: \.self) { s in
                HStack(spacing: 0) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(s.rawValue <= step.rawValue ? Color(hex: "#E91E8C") : Color.gray.opacity(0.2))
                                .frame(width: 28, height: 28)
                            if s.rawValue < step.rawValue {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(s.rawValue + 1)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(s.rawValue <= step.rawValue ? .white : .gray)
                            }
                        }
                        Text(["Address", "Payment", "Review"][s.rawValue])
                            .font(.system(size: 10))
                            .foregroundColor(s.rawValue <= step.rawValue ? Color(hex: "#E91E8C") : .gray)
                    }
                    if s != .review {
                        Rectangle()
                            .fill(s.rawValue < step.rawValue ? Color(hex: "#E91E8C") : Color.gray.opacity(0.2))
                            .frame(height: 2)
                            .padding(.bottom, 18)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(Color.white)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    // MARK: - Address Step
    var addressStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Delivery Address")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            if let addresses = authVM.currentUser?.addresses, !addresses.isEmpty {
                ForEach(addresses) { address in
                    AddressCard(address: address,
                                isSelected: selectedAddressId == address.id || (selectedAddressId == nil && addresses.first?.id == address.id))
                    .onTapGesture { selectedAddressId = address.id }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "mappin.slash")
                        .font(.system(size: 40))
                        .foregroundColor(Color.gray.opacity(0.3))
                    Text("No saved addresses")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            }

            Button {
                showAddAddress = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Address")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "#E91E8C"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "#FFE4F2"))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Payment Step
    var paymentStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Payment Method")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            ForEach(PaymentMethod.allCases, id: \.self) { method in
                VStack(spacing: 0) {
                    Button {
                        selectedPayment = method
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: method.icon)
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#9C27B0"))
                                .frame(width: 28)
                            Text(method.rawValue)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "#1A0533"))
                            Spacer()
                            Image(systemName: selectedPayment == method ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedPayment == method ? Color(hex: "#E91E8C") : .gray)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                            selectedPayment == method ? Color(hex: "#E91E8C") : Color.clear, lineWidth: 1.5))
                    }

                    // Payment details input
                    if selectedPayment == method {
                        paymentDetails(for: method)
                    }
                }
                .shadow(color: .black.opacity(0.04), radius: 4)
            }
        }
    }

    @ViewBuilder
    func paymentDetails(for method: PaymentMethod) -> some View {
        switch method {
        case .upi:
            VStack(spacing: 12) {
                BoutiqueTextField(placeholder: "Enter UPI ID (e.g. name@upi)", text: $upiId,
                                  icon: "indianrupeesign.circle")
                Text("You'll receive a payment request on your UPI app")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color(hex: "#F8F0FF"))
            .cornerRadius(bottomLeft: 12, bottomRight: 12)

        case .creditCard, .debitCard:
            VStack(spacing: 12) {
                BoutiqueTextField(placeholder: "Card Number", text: $cardNumber,
                                  icon: "creditcard", keyboardType: .numberPad)
                BoutiqueTextField(placeholder: "Cardholder Name", text: $cardHolderName, icon: "person")
                HStack(spacing: 12) {
                    BoutiqueTextField(placeholder: "MM/YY", text: $cardExpiry,
                                      icon: "calendar", keyboardType: .numberPad)
                    BoutiqueTextField(placeholder: "CVV", text: $cardCVV,
                                      icon: "lock", keyboardType: .numberPad)
                }
            }
            .padding(16)
            .background(Color(hex: "#F8F0FF"))
            .cornerRadius(bottomLeft: 12, bottomRight: 12)

        case .cashOnDelivery:
            HStack(spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundColor(Color(hex: "#9C27B0"))
                Text("Pay with cash when your order is delivered")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color(hex: "#F8F0FF"))
            .cornerRadius(bottomLeft: 12, bottomRight: 12)
        }
    }

    // MARK: - Review Step
    var reviewStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Review Your Order")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))

            // Items
            VStack(alignment: .leading, spacing: 12) {
                Text("Items (\(cartVM.itemCount))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                ForEach(cartVM.items) { item in
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: item.product.category.color).opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: item.product.category.icon)
                                .foregroundColor(Color(hex: item.product.category.color).opacity(0.4))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.product.name).font(.system(size: 12, weight: .medium)).lineLimit(1)
                            Text("\(item.selectedSize) · \(item.selectedColor) · Qty \(item.quantity)")
                                .font(.system(size: 11)).foregroundColor(.gray)
                            if item.serviceType == .rent {
                                Text("Rent · \(item.rentalDays) days")
                                    .font(.system(size: 10)).foregroundColor(Color(hex: "#E91E8C"))
                            }
                        }
                        Spacer()
                        Text("₹\(Int(item.totalPrice))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "#E91E8C"))
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 4)

            // Delivery address
            if let address = selectedAddress {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Delivery Address").font(.system(size: 14, weight: .medium)).foregroundColor(.gray)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(address.recipientName).font(.system(size: 14, weight: .semibold))
                        Text(address.fullAddress).font(.system(size: 13)).foregroundColor(.gray)
                        Text(address.mobileNumber).font(.system(size: 13)).foregroundColor(.gray)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.04), radius: 4)
            }

            // Payment
            VStack(alignment: .leading, spacing: 8) {
                Text("Payment Method").font(.system(size: 14, weight: .medium)).foregroundColor(.gray)
                HStack(spacing: 10) {
                    Image(systemName: selectedPayment.icon)
                        .foregroundColor(Color(hex: "#9C27B0"))
                    Text(selectedPayment.rawValue).font(.system(size: 14, weight: .medium))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 4)

            // Total
            HStack {
                Text("Total Amount").font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("₹\(Int(cartVM.totalAmount))")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#E91E8C"))
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 4)
        }
    }

    // MARK: - Action Bar
    var actionBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                if step != .address {
                    Button("Back") {
                        withAnimation { step = CheckoutStep(rawValue: step.rawValue - 1)! }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#9C27B0"))
                    .frame(width: 80, height: 50)
                    .background(Color(hex: "#F0E6FF"))
                    .cornerRadius(12)
                }

                Button {
                    if step == .review {
                        placeOrder()
                    } else {
                        withAnimation { step = CheckoutStep(rawValue: step.rawValue + 1)! }
                    }
                } label: {
                    Text(step == .review ? "Place Order" : "Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            canProceed
                            ? LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                }
                .disabled(!canProceed)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }

    // MARK: - Order Success
    var orderSuccessView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(hex: "#E8F5E9"))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }
            Text("Order Placed! 🎉")
                .font(.custom("Georgia-Bold", size: 28))
                .foregroundColor(Color(hex: "#1A0533"))
            Text("Your order has been placed successfully.\nYou'll receive a confirmation soon.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            VStack(spacing: 10) {
                Text("Payment Method: \(selectedPayment.rawValue)")
                    .font(.system(size: 14)).foregroundColor(.gray)
                Text("Total Paid: ₹\(Int(cartVM.totalAmount))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#E91E8C"))
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Continue Shopping")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
    }

    func placeOrder() {
        guard let address = selectedAddress else { return }
        let order = Order(items: cartVM.items, shippingAddress: address,
                          paymentMethod: selectedPayment, totalAmount: cartVM.totalAmount)
        authVM.addOrder(order)
        cartVM.clearCart()
        withAnimation { orderPlaced = true }
    }
}

// MARK: - Address Card
struct AddressCard: View {
    let address: ShippingAddress
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Color(hex: "#E91E8C") : .gray)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(address.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(isSelected ? Color(hex: "#E91E8C") : Color.gray)
                        .cornerRadius(6)
                    Spacer()
                }
                Text(address.recipientName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A0533"))
                Text(address.fullAddress)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                Text(address.mobileNumber)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(
            isSelected ? Color(hex: "#E91E8C") : Color.clear, lineWidth: 1.5))
        .shadow(color: .black.opacity(0.04), radius: 4)
    }
}

// MARK: - Add Address View
struct AddAddressView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var label = "Home"
    @State private var name = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var pinCode = ""
    @State private var mobile = ""
    let labels = ["Home", "Work", "Other"]

    var isValid: Bool {
        !name.isEmpty && !street.isEmpty && !city.isEmpty && !state.isEmpty &&
        pinCode.count == 6 && mobile.count == 10
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // Label selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Address Type").font(.system(size: 14, weight: .semibold))
                            HStack(spacing: 10) {
                                ForEach(labels, id: \.self) { l in
                                    Button {
                                        label = l
                                    } label: {
                                        Text(l)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(label == l ? .white : Color(hex: "#4A0E5E"))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(label == l ? Color(hex: "#E91E8C") : Color(hex: "#F0E6FF"))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }

                        BoutiqueTextField(placeholder: "Full Name", text: $name, icon: "person")
                        BoutiqueTextField(placeholder: "Street Address", text: $street, icon: "house")
                        BoutiqueTextField(placeholder: "City", text: $city, icon: "building.2")
                        BoutiqueTextField(placeholder: "State", text: $state, icon: "map")
                        BoutiqueTextField(placeholder: "PIN Code", text: $pinCode, icon: "location", keyboardType: .numberPad)
                        BoutiqueTextField(placeholder: "Mobile Number", text: $mobile, icon: "phone", keyboardType: .phonePad)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Address")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }.foregroundColor(Color(hex: "#9C27B0")),
                trailing: Button("Save") {
                    let address = ShippingAddress(label: label, recipientName: name,
                                                  streetAddress: street, city: city,
                                                  state: state, pinCode: pinCode, mobileNumber: mobile)
                    authVM.addAddress(address)
                    dismiss()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isValid ? Color(hex: "#E91E8C") : .gray)
                .disabled(!isValid)
            )
        }
    }
}

// Corner radius extension
extension View {
    func cornerRadius(bottomLeft: CGFloat, bottomRight: CGFloat) -> some View {
        clipShape(RoundedCorner(bottomLeft: bottomLeft, bottomRight: bottomRight))
    }
}

struct RoundedCorner: Shape {
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
                          control: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
