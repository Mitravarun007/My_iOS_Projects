//
//  VijayLaxmiCaterServicesApp.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

@main
struct VijayLaxmiCaterServicesApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var cateringService = CateringService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(cateringService)
        }
    }
}