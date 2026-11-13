import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                MyBillsView()
            }
            .tabItem { Label("My Bills", systemImage: "square.stack.3d.up.fill") }

            NavigationStack {
                NotificationsView()
            }
            .tabItem { Label("Notifications", systemImage: "bell.fill") }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Bill.self, Claim.self, ClaimTag.self], inMemory: true)
}
