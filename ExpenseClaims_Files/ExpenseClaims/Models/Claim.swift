import Foundation
import SwiftData

@Model
final class Claim {
    var id: UUID
    var createdAt: Date
    var submittedAt: Date?
    var statusRaw: String

    // Per-bill claim details keyed by bill id (simple form fields captured in Raise Claim screen)
    var employeeContribution: Double
    var clientRecoverable: Bool
    var clientEntertained: String
    var hotelOrRestaurantName: String
    var attendeeNames: [String]
    var remarks: String

    @Relationship(deleteRule: .nullify, inverse: \Bill.claim)
    var bills: [Bill]

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        submittedAt: Date? = nil,
        status: ClaimStatus = .draft,
        employeeContribution: Double = 0,
        clientRecoverable: Bool = false,
        clientEntertained: String = "",
        hotelOrRestaurantName: String = "",
        attendeeNames: [String] = [],
        remarks: String = "",
        bills: [Bill] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.submittedAt = submittedAt
        self.statusRaw = status.rawValue
        self.employeeContribution = employeeContribution
        self.clientRecoverable = clientRecoverable
        self.clientEntertained = clientEntertained
        self.hotelOrRestaurantName = hotelOrRestaurantName
        self.attendeeNames = attendeeNames
        self.remarks = remarks
        self.bills = bills
    }

    var status: ClaimStatus {
        get { ClaimStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    var totalAmount: Double {
        bills.reduce(0) { $0 + $1.amount }
    }
}
