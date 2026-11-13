import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showCheckout = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                if cartVM.items.isEmpty {
                    emptyCartView
                } else {
                    VStack(spacing: 0) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(cartVM.items) { item in
                                    CartItemRow(item: item)
                                        .environmentObject(cartVM)
                                }

                                // Price summary card
                                priceSummaryCard
                            }
                            .padding(16)
                        }

                        // Checkout bar
                        checkoutBar
                    }
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !cartVM.items.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            cartVM.clearCart()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showCheckout) {
            CheckoutView()
                .environmentObject(cartVM)
                .environmentObject(authVM)
        }
    }

    var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "#E91E8C").opacity(0.3))
            Text("Your cart is empty")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))
            Text("Add items from the shop to get started")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }

    var priceSummaryCard: some View {
        VStack(spacing: 12) {
            Text("Order Summary")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#1A0533"))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                summaryRow(label: "Items (\(cartVM.itemCount))", value: "₹\(Int(cartVM.totalAmount))")
                summaryRow(label: "Delivery", value: cartVM.totalAmount > 999 ? "FREE" : "₹99")
                    .foregroundColor(cartVM.totalAmount > 999 ? .green : .primary)
                Divider()
                HStack {
                    Text("Total Amount")
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                    Text("₹\(Int(cartVM.totalAmount + (cartVM.totalAmount > 999 ? 0 : 99)))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#E91E8C"))
                }
                if cartVM.totalAmount <= 999 {
                    Text("Add ₹\(Int(999 - cartVM.totalAmount)) more for FREE delivery")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundColor(.gray)
            Spacer()
            Text(value).font(.system(size: 13, weight: .medium))
        }
    }

    var checkoutBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(cartVM.itemCount) items")
                        .font(.system(size: 12)).foregroundColor(.gray)
                    Text("₹\(Int(cartVM.totalAmount))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#E91E8C"))
                }
                Spacer()
                Button {
                    showCheckout = true
                } label: {
                    Text("Proceed to Checkout")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
        }
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartVM: CartViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: item.product.category.color).opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: item.product.category.icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: item.product.category.color).opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A0533"))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(item.selectedSize, systemImage: "ruler")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Label(item.selectedColor, systemImage: "circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                if item.serviceType == .rent {
                    Text("Rent · \(item.rentalDays) days")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#E91E8C"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#FFE4F2"))
                        .cornerRadius(6)
                }

                HStack {
                    Text("₹\(Int(item.totalPrice))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#E91E8C"))

                    Spacer()

                    // Quantity stepper
                    HStack(spacing: 8) {
                        Button {
                            cartVM.updateQuantity(item, quantity: item.quantity - 1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(item.quantity == 1 ? .red.opacity(0.6) : Color(hex: "#9C27B0"))
                        }
                        Text("\(item.quantity)")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 20, alignment: .center)
                        Button {
                            cartVM.updateQuantity(item, quantity: item.quantity + 1)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#9C27B0"))
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                cartVM.removeItem(item)
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}
