import SwiftUI

// MARK: - Orders View
struct OrdersView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedOrder: Order?

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                if let orders = authVM.currentUser?.orders, !orders.isEmpty {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(orders) { order in
                                OrderCard(order: order)
                                    .onTapGesture { selectedOrder = order }
                            }
                        }
                        .padding(16)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#E91E8C").opacity(0.3))
                        Text("No orders yet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A0533"))
                        Text("Your orders will appear here after shopping")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationTitle("My Orders")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedOrder) { order in
            OrderDetailView(order: order)
        }
    }
}

struct OrderCard: View {
    let order: Order

    var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Order #\(order.id.uuidString.prefix(8).uppercased())")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A0533"))
                    Text(dateFormatter.string(from: order.orderDate))
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: order.status.icon)
                        .font(.system(size: 11))
                    Text(order.status.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: order.status.color))
                .cornerRadius(20)
            }

            // Items preview
            HStack(spacing: 8) {
                ForEach(order.items.prefix(3)) { item in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: item.product.category.color).opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: item.product.category.icon)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: item.product.category.color).opacity(0.5))
                    }
                }
                if order.items.count > 3 {
                    Text("+\(order.items.count - 3)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(order.items.count) items")
                        .font(.system(size: 12)).foregroundColor(.gray)
                    Text("₹\(Int(order.totalAmount))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "#E91E8C"))
                }
            }

            HStack(spacing: 6) {
                Image(systemName: order.paymentMethod.icon)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(order.paymentMethod.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Order Detail View
struct OrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Status
                        VStack(spacing: 8) {
                            Image(systemName: order.status.icon)
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: order.status.color))
                            Text(order.status.rawValue)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: order.status.color))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(14)

                        // Items
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Items").font(.system(size: 15, weight: .semibold))
                            ForEach(order.items) { item in
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: item.product.category.color).opacity(0.1))
                                            .frame(width: 56, height: 56)
                                        Image(systemName: item.product.category.icon)
                                            .foregroundColor(Color(hex: item.product.category.color).opacity(0.4))
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.product.name).font(.system(size: 13, weight: .medium)).lineLimit(2)
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
                        .cornerRadius(14)

                        // Delivery Address
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Delivery Address").font(.system(size: 15, weight: .semibold))
                            Text(order.shippingAddress.recipientName).font(.system(size: 14, weight: .medium))
                            Text(order.shippingAddress.fullAddress).font(.system(size: 13)).foregroundColor(.gray)
                            Text(order.shippingAddress.mobileNumber).font(.system(size: 13)).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)

                        // Payment
                        HStack {
                            Text("Payment").font(.system(size: 15, weight: .semibold))
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: order.paymentMethod.icon).foregroundColor(Color(hex: "#9C27B0"))
                                Text(order.paymentMethod.rawValue).font(.system(size: 14))
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)

                        // Total
                        HStack {
                            Text("Total").font(.system(size: 16, weight: .bold))
                            Spacer()
                            Text("₹\(Int(order.totalAmount))").font(.system(size: 18, weight: .bold)).foregroundColor(Color(hex: "#E91E8C"))
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() }.foregroundColor(Color(hex: "#9C27B0")))
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showAddAddress = false
    @State private var showEditProfile = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FAF5FF").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Profile header
                        profileHeader

                        VStack(spacing: 12) {
                            // Account section
                            profileSection(title: "Account") {
                                ProfileRow(icon: "person.circle", title: "Personal Details",
                                           subtitle: authVM.currentUser?.email ?? "")
                                Divider().padding(.leading, 54)
                                ProfileRow(icon: "phone.circle", title: "Mobile Number",
                                           subtitle: authVM.currentUser?.mobileNumber ?? "")
                            }

                            // Addresses section
                            profileSection(title: "Saved Addresses") {
                                if let addresses = authVM.currentUser?.addresses, !addresses.isEmpty {
                                    ForEach(Array(addresses.enumerated()), id: \.element.id) { idx, address in
                                        if idx > 0 { Divider().padding(.leading, 54) }
                                        ProfileRow(icon: "mappin.circle", title: address.label,
                                                   subtitle: address.fullAddress)
                                    }
                                    Divider().padding(.leading, 54)
                                }
                                Button {
                                    showAddAddress = true
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "#E91E8C"))
                                            .frame(width: 28)
                                        Text("Add New Address")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(hex: "#E91E8C"))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 13)
                                }
                            }

                            // App section
                            profileSection(title: "App") {
                                ProfileRow(icon: "bell.circle", title: "Notifications", subtitle: "")
                                Divider().padding(.leading, 54)
                                ProfileRow(icon: "questionmark.circle", title: "Help & Support", subtitle: "")
                                Divider().padding(.leading, 54)
                                ProfileRow(icon: "doc.text", title: "Terms & Privacy", subtitle: "")
                            }

                            // Logout
                            Button {
                                authVM.logout()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.white)
                                .cornerRadius(14)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showAddAddress) {
            AddAddressView().environmentObject(authVM)
        }
    }

    var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "#E91E8C"), Color(hex: "#9C27B0")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 84, height: 84)
                Text(String(authVM.currentUser?.fullName.prefix(1).uppercased() ?? "U"))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(authVM.currentUser?.fullName ?? "User")
                .font(.custom("Georgia-Bold", size: 20))
                .foregroundColor(Color(hex: "#1A0533"))
            Text(authVM.currentUser?.email ?? "")
                .font(.system(size: 13))
                .foregroundColor(.gray)

            // Stats row
            HStack(spacing: 0) {
                statItem(value: "\(authVM.currentUser?.orders.count ?? 0)", label: "Orders")
                Divider().frame(height: 30)
                statItem(value: "\(authVM.currentUser?.addresses.count ?? 0)", label: "Addresses")
                Divider().frame(height: 30)
                statItem(value: "\(authVM.currentUser?.orders.filter { $0.items.contains(where: { $0.serviceType == .rent }) }.count ?? 0)", label: "Rentals")
            }
            .background(Color(hex: "#F0E6FF"))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(colors: [Color.white, Color(hex: "#FAF5FF")], startPoint: .top, endPoint: .bottom)
        )
    }

    func statItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(Color(hex: "#E91E8C"))
            Text(label).font(.system(size: 11)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    func profileSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .kerning(0.5)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 4)
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "#9C27B0"))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15)).foregroundColor(Color(hex: "#1A0533"))
                if !subtitle.isEmpty {
                    Text(subtitle).font(.system(size: 12)).foregroundColor(.gray).lineLimit(1)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}
