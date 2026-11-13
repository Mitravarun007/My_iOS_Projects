//
//  BookingView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct BookingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var cateringService: CateringService
    
    @State private var selectedServiceType: ServiceType = .birthday
    @State private var eventDate = Date().addingTimeInterval(86400) // Tomorrow
    @State private var guestCount = "50"
    @State private var contactPhone = ""
    @State private var venue = ""
    @State private var specialRequests = ""
    @State private var selectedThalis: [ThaliItem] = []
    @State private var selectedBuffetItems: [BuffetItem] = []
    @State private var showingConfirmation = false
    @State private var bookingSuccess = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var totalAmount: Double {
        guard let guests = Int(guestCount) else { return 0 }
        return cateringService.calculateTotalPrice(
            thalis: selectedThalis,
            buffetItems: selectedBuffetItems,
            guestCount: guests
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Event Details Section
                    EventDetailsSection()
                    
                    // Menu Selection Section
                    MenuSelectionSection()
                    
                    // Additional Information
                    AdditionalInfoSection()
                    
                    // Price Summary
                    PriceSummarySection()
                    
                    // Book Now Button
                    BookNowButton()
                }
                .padding()
            }
            .navigationTitle("Book Event")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingConfirmation) {
            BookingConfirmationSheet()
        }
        .alert(bookingSuccess ? "Booking Confirmed!" : "Booking Error", isPresented: $showingAlert) {
            Button("OK") {
                if bookingSuccess {
                    resetForm()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Event Details Section
    @ViewBuilder
    private func EventDetailsSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Event Details", icon: "calendar.badge.plus")
            
            VStack(spacing: 15) {
                // Service Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Type")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Picker("Service Type", selection: $selectedServiceType) {
                        ForEach(ServiceType.allCases) { serviceType in
                            Text(serviceType.rawValue).tag(serviceType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Date")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    DatePicker("Select Date", selection: $eventDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Guest Count
                VStack(alignment: .leading, spacing: 8) {
                    Text("Number of Guests")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("Enter guest count", text: $guestCount)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Menu Selection Section
    @ViewBuilder
    private func MenuSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Menu Selection", icon: "menucard.fill")
            
            VStack(spacing: 15) {
                // Thali Selection
                NavigationLink(destination: ThaliSelectionView(selectedThalis: $selectedThalis)) {
                    MenuSelectionRow(
                        title: "Thali System",
                        subtitle: selectedThalis.isEmpty ? "Tap to select thalis" : "\(selectedThalis.count) thali(s) selected",
                        icon: "leaf.fill"
                    )
                }
                
                // Buffet Selection
                NavigationLink(destination: BuffetSelectionView(selectedBuffetItems: $selectedBuffetItems)) {
                    MenuSelectionRow(
                        title: "Buffet Items",
                        subtitle: selectedBuffetItems.isEmpty ? "Tap to select items" : "\(selectedBuffetItems.count) item(s) selected",
                        icon: "fork.knife"
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Additional Info Section
    @ViewBuilder
    private func AdditionalInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Additional Information", icon: "info.circle.fill")
            
            VStack(spacing: 15) {
                // Contact Phone
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact Phone")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("Enter contact number", text: $contactPhone)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Venue
                VStack(alignment: .leading, spacing: 8) {
                    Text("Venue Address")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("Enter venue address", text: $venue, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Special Requests
                VStack(alignment: .leading, spacing: 8) {
                    Text("Special Requests (Optional)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("Any special requirements...", text: $specialRequests, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Price Summary Section
    @ViewBuilder
    private func PriceSummarySection() -> some View {
        if !selectedThalis.isEmpty || !selectedBuffetItems.isEmpty {
            VStack(alignment: .leading, spacing: 15) {
                SectionHeader(title: "Price Summary", icon: "indianrupeesign.circle.fill")
                
                VStack(spacing: 10) {
                    if !selectedThalis.isEmpty, let guests = Int(guestCount) {
                        ForEach(selectedThalis) { thali in
                            PriceSummaryRow(
                                title: thali.name,
                                subtitle: "₹\(Int(thali.price)) × \(guests) guests",
                                amount: thali.price * Double(guests)
                            )
                        }
                    }
                    
                    if !selectedBuffetItems.isEmpty, let guests = Int(guestCount) {
                        ForEach(selectedBuffetItems) { item in
                            PriceSummaryRow(
                                title: item.name,
                                subtitle: "₹\(Int(item.pricePerPerson)) × \(guests) guests",
                                amount: item.pricePerPerson * Double(guests)
                            )
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total Amount")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("₹\(Int(totalAmount))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    // MARK: - Book Now Button
    @ViewBuilder
    private func BookNowButton() -> some View {
        Button(action: {
            showingConfirmation = true
        }) {
            Text("Book Now")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
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
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
    }
    
    // MARK: - Booking Confirmation Sheet
    @ViewBuilder
    private func BookingConfirmationSheet() -> some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Confirmation Header
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Confirm Your Booking")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    // Booking Summary
                    VStack(alignment: .leading, spacing: 15) {
                        BookingSummaryRow(title: "Event Type", value: selectedServiceType.rawValue)
                        BookingSummaryRow(title: "Date", value: eventDate.formatted(date: .long, time: .omitted))
                        BookingSummaryRow(title: "Guests", value: guestCount)
                        BookingSummaryRow(title: "Contact", value: contactPhone)
                        BookingSummaryRow(title: "Venue", value: venue)
                        
                        if !specialRequests.isEmpty {
                            BookingSummaryRow(title: "Special Requests", value: specialRequests)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Amount")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("₹\(Int(totalAmount))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Confirmation Buttons
                    VStack(spacing: 15) {
                        Button(action: confirmBooking) {
                            Text("Confirm Booking")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        
                        Button(action: { showingConfirmation = false }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Confirm Booking")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Helper Methods
    private var isFormValid: Bool {
        !contactPhone.isEmpty && !venue.isEmpty && 
        (!selectedThalis.isEmpty || !selectedBuffetItems.isEmpty) &&
        Int(guestCount) != nil && Int(guestCount)! > 0
    }
    
    private func confirmBooking() {
        guard let guests = Int(guestCount),
              let userId = authManager.currentUser?.id else {
            alertMessage = "Please check your booking details"
            showingAlert = true
            return
        }
        
        let booking = Booking(
            userId: userId,
            serviceType: selectedServiceType,
            eventDate: eventDate,
            guestCount: guests,
            selectedThalis: selectedThalis,
            selectedBuffetItems: selectedBuffetItems,
            specialRequests: specialRequests,
            contactPhone: contactPhone,
            venue: venue
        )
        
        cateringService.addBooking(booking)
        
        alertMessage = "Your booking has been confirmed! We'll contact you soon."
        bookingSuccess = true
        showingAlert = true
        showingConfirmation = false
    }
    
    private func resetForm() {
        selectedServiceType = .birthday
        eventDate = Date().addingTimeInterval(86400)
        guestCount = "50"
        contactPhone = ""
        venue = ""
        specialRequests = ""
        selectedThalis = []
        selectedBuffetItems = []
    }
}

// MARK: - Helper Views
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
    }
}

struct MenuSelectionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct PriceSummaryRow: View {
    let title: String
    let subtitle: String
    let amount: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("₹\(Int(amount))")
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}

struct BookingSummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    BookingView()
        .environmentObject(AuthenticationManager())
        .environmentObject(CateringService())
}