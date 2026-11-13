//
//  CateringService.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import Foundation
import SwiftUI

class CateringService: ObservableObject {
    @Published var thaliItems: [ThaliItem] = []
    @Published var buffetItems: [BuffetItem] = []
    @Published var userBookings: [Booking] = []
    
    private let userDefaults = UserDefaults.standard
    private let bookingsKey = "UserBookings"
    
    init() {
        loadSampleData()
        loadBookings()
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        // Sample Thali Items
        thaliItems = [
            ThaliItem(
                name: "Royal Thali",
                description: "Premium thali with special delicacies",
                price: 350.0,
                items: ["Dal Makhani", "Paneer Butter Masala", "Jeera Rice", "Naan", "Raita", "Pickle", "Sweet"]
            ),
            ThaliItem(
                name: "Deluxe Thali",
                description: "Complete traditional thali",
                price: 250.0,
                items: ["Dal Tadka", "Aloo Gobi", "Chapati", "Rice", "Raita", "Pickle", "Gulab Jamun"]
            ),
            ThaliItem(
                name: "Standard Thali",
                description: "Simple and nutritious thali",
                price: 180.0,
                items: ["Dal", "Sabzi", "Chapati", "Rice", "Pickle", "Sweet"]
            ),
            ThaliItem(
                name: "Gujarati Thali",
                description: "Authentic Gujarati cuisine",
                price: 300.0,
                items: ["Gujarati Dal", "Undhiyu", "Thepla", "Khichdi", "Dhokla", "Shrikhand"]
            )
        ]
        
        // Sample Buffet Items
        buffetItems = [
            // Starters
            BuffetItem(
                name: "Paneer Tikka",
                description: "Grilled cottage cheese with spices",
                pricePerPerson: 80.0,
                category: .starter
            ),
            BuffetItem(
                name: "Veg Spring Rolls",
                description: "Crispy vegetable spring rolls",
                pricePerPerson: 60.0,
                category: .starter
            ),
            BuffetItem(
                name: "Aloo Tikki",
                description: "Spiced potato cutlets",
                pricePerPerson: 50.0,
                category: .starter
            ),
            
            // Main Course
            BuffetItem(
                name: "Paneer Butter Masala",
                description: "Cottage cheese in rich tomato gravy",
                pricePerPerson: 120.0,
                category: .mainCourse
            ),
            BuffetItem(
                name: "Dal Makhani",
                description: "Creamy black lentil curry",
                pricePerPerson: 100.0,
                category: .mainCourse
            ),
            BuffetItem(
                name: "Veg Biryani",
                description: "Aromatic basmati rice with vegetables",
                pricePerPerson: 150.0,
                category: .mainCourse
            ),
            BuffetItem(
                name: "Butter Naan",
                description: "Soft bread with butter",
                pricePerPerson: 40.0,
                category: .mainCourse
            ),
            
            // Desserts
            BuffetItem(
                name: "Gulab Jamun",
                description: "Sweet milk dumplings in syrup",
                pricePerPerson: 60.0,
                category: .dessert
            ),
            BuffetItem(
                name: "Rasmalai",
                description: "Cottage cheese balls in sweet milk",
                pricePerPerson: 80.0,
                category: .dessert
            ),
            BuffetItem(
                name: "Ice Cream",
                description: "Vanilla and chocolate ice cream",
                pricePerPerson: 50.0,
                category: .dessert
            ),
            
            // Drinks
            BuffetItem(
                name: "Fresh Lime Water",
                description: "Refreshing lime drink",
                pricePerPerson: 30.0,
                category: .drinks
            ),
            BuffetItem(
                name: "Lassi",
                description: "Traditional yogurt drink",
                pricePerPerson: 40.0,
                category: .drinks
            )
        ]
    }
    
    // MARK: - Booking Management
    func addBooking(_ booking: Booking) {
        userBookings.append(booking)
        saveBookings()
    }
    
    func updateBookingStatus(_ bookingId: UUID, status: BookingStatus) {
        if let index = userBookings.firstIndex(where: { $0.id == bookingId }) {
            userBookings[index].bookingStatus = status
            saveBookings()
        }
    }
    
    func getBookings(for userId: UUID) -> [Booking] {
        return userBookings.filter { $0.userId == userId }
    }
    
    // MARK: - Utility Methods
    func getBuffetItems(for category: BuffetCategory) -> [BuffetItem] {
        return buffetItems.filter { $0.category == category }
    }
    
    func calculateTotalPrice(thalis: [ThaliItem], buffetItems: [BuffetItem], guestCount: Int) -> Double {
        let thaliTotal = thalis.reduce(0) { $0 + ($1.price * Double(guestCount)) }
        let buffetTotal = buffetItems.reduce(0) { $0 + ($1.pricePerPerson * Double(guestCount)) }
        return thaliTotal + buffetTotal
    }
    
    // MARK: - Persistence
    private func saveBookings() {
        guard let encoded = try? JSONEncoder().encode(userBookings) else { return }
        userDefaults.set(encoded, forKey: bookingsKey)
    }
    
    private func loadBookings() {
        guard let data = userDefaults.data(forKey: bookingsKey),
              let bookings = try? JSONDecoder().decode([Booking].self, from: data) else {
            return
        }
        userBookings = bookings
    }
}