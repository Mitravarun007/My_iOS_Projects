//
//  MadhoorBoutiqueApp.swift
//  MadhoorBoutique
//
//  Created by Mitravarun Chauhan on 23/03/26.
//

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
