//
//  MainTabView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var cateringService: CateringService
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            MenuView()
                .tabItem {
                    Image(systemName: "menucard.fill")
                    Text("Menu")
                }
            
            BookingView()
                .tabItem {
                    Image(systemName: "calendar.badge.plus")
                    Text("Book Now")
                }
            
            MyBookingsView()
                .tabItem {
                    Image(systemName: "list.clipboard.fill")
                    Text("My Bookings")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
        .environmentObject(CateringService())
}