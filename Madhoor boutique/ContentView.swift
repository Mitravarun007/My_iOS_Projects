import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var cartVM: CartViewModel
    @StateObject var productsVM = ProductsViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if authVM.isLoggedIn {
                MainTabView(selectedTab: $selectedTab)
                    .environmentObject(productsVM)
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut, value: authVM.isLoggedIn)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ShopView()
                .tabItem {
                    Label("Shop", systemImage: "bag.fill")
                }
                .tag(1)

            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
                .badge(cartVM.itemCount > 0 ? "\(cartVM.itemCount)" : nil)
                .tag(2)

            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(Color("PrimaryPink"))
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "TabBarBG") ?? .systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
