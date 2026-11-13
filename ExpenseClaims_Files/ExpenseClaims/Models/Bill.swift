import Foundation
import SwiftData

@Model
final class Bill {
    var id: UUID
    var createdAt: Date

    // Category & currency selected before capture
    var categoryRaw: String
    var currencyRaw: String

    // Captured receipt image, stored as raw data (JPEG)
    @Attribute(.externalStorage) var imageData: Data?
    var sourceFileName: String?

    // Extracted / entered bill fields
    var vendorName: String
    var billDate: Date
    var amount: Double
    var extractedRawText: String?

    // Organisation
    var tagName: String?
    var statusRaw: String

    // Link back to a claim once raised
    var claim: Claim?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        category: ClaimCategory,
        currency: Currency = .usd,
        imageData: Data? = nil,
        sourceFileName: String? = nil,
        vendorName: String = "",
        billDate: Date = .now,
        amount: Double = 0,
        extractedRawText: String? = nil,
        tagName: String? = nil,
        status: BillStatus = .unclaimed
    ) {
        self.id = id
        self.createdAt = createdAt
        self.categoryRaw = category.rawValue
        self.currencyRaw = currency.rawValue
        self.imageData = imageData
        self.sourceFileName = sourceFileName
        self.vendorName = vendorName
        self.billDate = billDate
        self.amount = amount
        self.extractedRawText = extractedRawText
        self.tagName = tagName
        self.statusRaw = status.rawValue
    }

    var category: ClaimCategory {
        get { ClaimCategory(rawValue: categoryRaw) ?? .officeExpense }
        set { categoryRaw = newValue.rawValue }
    }

    var currency: Currency {
        get { Currency(rawValue: currencyRaw) ?? .usd }
        set { currencyRaw = newValue.rawValue }
    }

    var status: BillStatus {
        get { BillStatus(rawValue: statusRaw) ?? .unclaimed }
        set { statusRaw = newValue.rawValue }
    }

    var formattedAmount: String {
        "\(currency.rawValue) \(String(format: "%.2f", amount))"
    }
}
