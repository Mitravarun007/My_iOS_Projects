import SwiftUI

@main
struct MadhoorBoutiqueApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var cartVM = CartViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(cartVM)
        }
    }
}
