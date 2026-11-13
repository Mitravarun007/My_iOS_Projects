//
//  MyBookingsView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct MyBookingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var cateringService: CateringService
    
    private var userBookings: [Booking] {
        guard let userId = authManager.currentUser?.id else { return [] }
        return cateringService.getBookings(for: userId).sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if userBookings.isEmpty {
                    EmptyBookingsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(userBookings) { booking in
                                BookingCard(booking: booking)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Bookings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct EmptyBookingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Bookings Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            Text("Your catering bookings will appear here")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: BookingView()) {
                Text("Book Your First Event")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
}

struct BookingCard: View {
    let booking: Booking
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(booking.serviceType.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(booking.eventDate.formatted(date: .long, time: .omitted))
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                StatusBadge(status: booking.bookingStatus)
            }
            
            // Quick Details
            HStack(spacing: 20) {
                DetailItem(icon: "person.2.fill", text: "\(booking.guestCount) guests")
                DetailItem(icon: "indianrupeesign.circle.fill", text: "₹\(Int(booking.totalAmount))")
            }
            
            if isExpanded {
                Divider()
                
                // Detailed Information
                VStack(alignment: .leading, spacing: 12) {
                    if !booking.selectedThalis.isEmpty {
                        SectionDetail(
                            title: "Thali Selection",
                            items: booking.selectedThalis.map { $0.name }
                        )
                    }
                    
                    if !booking.selectedBuffetItems.isEmpty {
                        SectionDetail(
                            title: "Buffet Items",
                            items: booking.selectedBuffetItems.map { $0.name }
                        )
                    }
                    
                    if !booking.venue.isEmpty {
                        InfoRow(title: "Venue", value: booking.venue)
                    }
                    
                    if !booking.contactPhone.isEmpty {
                        InfoRow(title: "Contact", value: booking.contactPhone)
                    }
                    
                    if !booking.specialRequests.isEmpty {
                        InfoRow(title: "Special Requests", value: booking.specialRequests)
                    }
                    
                    InfoRow(title: "Booking ID", value: booking.id.uuidString.prefix(8).uppercased())
                    InfoRow(title: "Booked On", value: booking.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
            }
            
            // Expand/Collapse Button
            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Spacer()
                    
                    Text(isExpanded ? "Show Less" : "Show Details")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: BookingStatus
    
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(8)
    }
}

struct DetailItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.orange)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct SectionDetail: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.orange)
            
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack {
                    Text("• \(item)")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    MyBookingsView()
        .environmentObject(AuthenticationManager())
        .environmentObject(CateringService())
}