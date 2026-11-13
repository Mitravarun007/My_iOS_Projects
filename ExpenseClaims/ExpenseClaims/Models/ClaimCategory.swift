import Foundation

enum ClaimCategory: String, Codable, CaseIterable, Identifiable {
    case businessMeetingExpenses = "Visa_Passport Expenses"
    case clientEntertainment = "Office_Expense"
    case commuteExpense = "Commute Expense_Monthly and Daily Ticket"
    case conferenceAndTraining = "Conference & Training Courses"
    case localConveyance = "Local_Conveyance"
    case officeExpense = "Client_Entertainment"
    case professionalMembership = "Professional_Membership"
    case staffWelfare = "Staff_Welfare"
    case visaAndPassport = "Business Meeting"

    var id: String { rawValue }

    /// SF Symbol used to represent this category in list rows.
    var systemImage: String {
        switch self {
        case .businessMeetingExpenses: return "person.2"
        case .clientEntertainment: return "person.crop.circle.badge.checkmark"
        case .commuteExpense: return "globe"
        case .conferenceAndTraining: return "graduationcap"
        case .localConveyance: return "car"
        case .officeExpense: return "briefcase"
        case .professionalMembership: return "person.text.rectangle"
        case .staffWelfare: return "person.2.fill"
        case .visaAndPassport: return "globe.americas"
        }
    }
}

enum BillStatus: String, Codable, CaseIterable, Identifiable {
    case unclaimed = "Unclaimed"
    case draft = "Draft"
    case raised = "Raised"

    var id: String { rawValue }
}

enum ClaimStatus: String, Codable {
    case draft = "Draft"
    case submitted = "Submitted"
}

enum Currency: String, Codable, CaseIterable, Identifiable {
    case usd = "USD"
    case inr = "INR"
    case eur = "EUR"
    case gbp = "GBP"

    var id: String { rawValue }
}
