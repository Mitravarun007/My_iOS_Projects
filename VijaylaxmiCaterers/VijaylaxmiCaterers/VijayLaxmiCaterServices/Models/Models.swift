//
//  Models.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import Foundation

// MARK: - User Model
struct User: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var phoneNumber: String
    var address: String
    
    init(name: String, email: String, phoneNumber: String, address: String) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = address
    }
}

// MARK: - Service Type
enum ServiceType: String, CaseIterable, Identifiable {
    case wedding = "Wedding"
    case birthday = "Birthday Party"
    case corporate = "Corporate Event"
    case anniversary = "Anniversary"
    case festival = "Festival Celebration"
    case other = "Other"
    
    var id: String { self.rawValue }
}

// MARK: - Menu Item Models
struct ThaliItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let items: [String]
    let isVegetarian: Bool
    
    init(name: String, description: String, price: Double, items: [String], isVegetarian: Bool = true) {
        self.name = name
        self.description = description
        self.price = price
        self.items = items
        self.isVegetarian = isVegetarian
    }
}

struct BuffetItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let pricePerPerson: Double
    let category: BuffetCategory
    let isVegetarian: Bool
    
    init(name: String, description: String, pricePerPerson: Double, category: BuffetCategory, isVegetarian: Bool = true) {
        self.name = name
        self.description = description
        self.pricePerPerson = pricePerPerson
        self.category = category
        self.isVegetarian = isVegetarian
    }
}

enum BuffetCategory: String, CaseIterable, Identifiable {
    case starter = "Starters"
    case mainCourse = "Main Course"
    case dessert = "Desserts"
    case drinks = "Drinks"
    
    var id: String { self.rawValue }
}

// MARK: - Booking Model
struct Booking: Identifiable, Codable {
    let id = UUID()
    var userId: UUID
    var serviceType: ServiceType
    var eventDate: Date
    var guestCount: Int
    var selectedThalis: [ThaliItem]
    var selectedBuffetItems: [BuffetItem]
    var totalAmount: Double
    var specialRequests: String
    var contactPhone: String
    var venue: String
    var bookingStatus: BookingStatus
    var createdAt: Date
    
    init(userId: UUID, serviceType: ServiceType, eventDate: Date, guestCount: Int, selectedThalis: [ThaliItem] = [], selectedBuffetItems: [BuffetItem] = [], specialRequests: String = "", contactPhone: String, venue: String) {
        self.userId = userId
        self.serviceType = serviceType
        self.eventDate = eventDate
        self.guestCount = guestCount
        self.selectedThalis = selectedThalis
        self.selectedBuffetItems = selectedBuffetItems
        self.specialRequests = specialRequests
        self.contactPhone = contactPhone
        self.venue = venue
        self.bookingStatus = .pending
        self.createdAt = Date()
        
        // Calculate total amount
        let thaliTotal = selectedThalis.reduce(0) { $0 + ($1.price * Double(guestCount)) }
        let buffetTotal = selectedBuffetItems.reduce(0) { $0 + ($1.pricePerPerson * Double(guestCount)) }
        self.totalAmount = thaliTotal + buffetTotal
    }
}

enum BookingStatus: String, CaseIterable, Identifiable, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var id: String { self.rawValue }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .completed: return "green"
        case .cancelled: return "red"
        }
    }
}