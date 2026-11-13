//
//  ProfileView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var cateringService: CateringService
    @State private var showingLogoutAlert = false
    
    private var userBookingsCount: Int {
        guard let userId = authManager.currentUser?.id else { return 0 }
        return cateringService.getBookings(for: userId).count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    ProfileHeader()
                    
                    // Quick Stats
                    UserStatsSection()
                    
                    // Profile Options
                    ProfileOptionsSection()
                    
                    // App Information
                    AppInfoSection()
                    
                    // Logout Button
                    LogoutButton()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
    
    @ViewBuilder
    private func ProfileHeader() -> some View {
        VStack(spacing: 15) {
            // Profile Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Text(authManager.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                )
            
            // User Details
            VStack(spacing: 5) {
                Text(authManager.currentUser?.name ?? "Guest User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(authManager.currentUser?.email ?? "No email")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
    
    @ViewBuilder
    private func UserStatsSection() -> some View {
        HStack(spacing: 20) {
            StatCard(title: "Total Bookings", value: "\(userBookingsCount)", icon: "calendar.badge.clock")
            StatCard(title: "Member Since", value: "2024", icon: "star.fill")
            StatCard(title: "Favorite", value: "Thalis", icon: "heart.fill")
        }
    }
    
    @ViewBuilder
    private func ProfileOptionsSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Account Settings")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            VStack(spacing: 0) {
                ProfileOptionRow(
                    icon: "person.circle",
                    title: "Personal Information",
                    subtitle: "Update your profile details"
                ) {
                    // Navigate to edit profile
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Manage notification preferences"
                ) {
                    // Navigate to notifications settings
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    icon: "heart",
                    title: "Favorite Items",
                    subtitle: "View your favorite dishes"
                ) {
                    // Navigate to favorites
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    subtitle: "Get help or contact us"
                ) {
                    // Navigate to help
                }
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private func AppInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("About")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            VStack(spacing: 0) {
                ProfileOptionRow(
                    icon: "info.circle",
                    title: "About VijayLaxmi Catering",
                    subtitle: "Learn more about our services"
                ) {
                    // Navigate to about page
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    icon: "star.circle",
                    title: "Rate Our App",
                    subtitle: "Share your experience"
                ) {
                    // Open app store rating
                }
                
                Divider()
                    .padding(.leading, 50)
                
                ProfileOptionRow(
                    icon: "doc.text",
                    title: "Terms & Privacy",
                    subtitle: "Read our terms and privacy policy"
                ) {
                    // Navigate to terms
                }
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private func LogoutButton() -> some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.body)
                
                Text("Logout")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.orange)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Additional Profile Views
struct PersonalInformationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var address: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Details") {
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Address", text: $address, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Personal Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save changes
                    }
                }
            }
            .onAppear {
                loadUserData()
            }
        }
    }
    
    private func loadUserData() {
        if let user = authManager.currentUser {
            name = user.name
            email = user.email
            phoneNumber = user.phoneNumber
            address = user.address
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .environmentObject(CateringService())
}