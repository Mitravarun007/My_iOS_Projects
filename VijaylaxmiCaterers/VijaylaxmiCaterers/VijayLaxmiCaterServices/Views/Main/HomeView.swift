//
//  HomeView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var cateringService: CateringService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    WelcomeHeader()
                    
                    // Service Categories
                    ServiceCategoriesSection()
                    
                    // Featured Items
                    FeaturedItemsSection()
                    
                    // Quick Stats
                    QuickStatsSection()
                    
                    // Contact Information
                    ContactSection()
                }
                .padding(.horizontal)
            }
            .navigationTitle("VijayLaxmi Catering")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WelcomeHeader: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Welcome back,")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(authManager.currentUser?.name ?? "Guest")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            Text("Making your celebrations memorable with delicious food")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.red.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
    }
}

struct ServiceCategoriesSection: View {
    let serviceTypes = ServiceType.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Our Services")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(serviceTypes) { serviceType in
                    ServiceCategoryCard(serviceType: serviceType)
                }
            }
        }
    }
}

struct ServiceCategoryCard: View {
    let serviceType: ServiceType
    
    private var serviceIcon: String {
        switch serviceType {
        case .wedding: return "heart.fill"
        case .birthday: return "birthday.cake"
        case .corporate: return "building.2"
        case .anniversary: return "heart.circle.fill"
        case .festival: return "star.fill"
        case .other: return "party.popper.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: serviceIcon)
                .font(.system(size: 30))
                .foregroundColor(.orange)
            
            Text(serviceType.rawValue)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct FeaturedItemsSection: View {
    @EnvironmentObject var cateringService: CateringService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Featured Thalis")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: MenuView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Array(cateringService.thaliItems.prefix(3))) { thali in
                        FeaturedThaliCard(thali: thali)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
}

struct FeaturedThaliCard: View {
    let thali: ThaliItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("₹\(Int(thali.price))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(thali.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(thali.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Text("\(thali.items.count) items")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 160)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct QuickStatsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Why Choose Us")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                QuickStatCard(icon: "star.fill", title: "5+ Years", subtitle: "Experience")
                QuickStatCard(icon: "heart.fill", title: "1000+", subtitle: "Happy Customers")
                QuickStatCard(icon: "checkmark.circle.fill", title: "100%", subtitle: "Quality Food")
            }
        }
    }
}

struct QuickStatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

struct ContactSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Contact Us")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                ContactRow(icon: "phone.fill", text: "+91 98765 43210")
                ContactRow(icon: "envelope.fill", text: "info@vijaylaxmicatering.com")
                ContactRow(icon: "location.fill", text: "123 Catering Street, Food City")
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationManager())
        .environmentObject(CateringService())
}