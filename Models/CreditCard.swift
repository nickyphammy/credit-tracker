import Foundation
import SwiftData

@Model
final class CreditCard {
    var id: UUID
    var name: String
    var issuer: String
    var credits: [Credit]
    var dateAdded: Date

    init(name: String, issuer: String) {
        self.id = UUID()
        self.name = name
        self.issuer = issuer
        self.credits = []
        self.dateAdded = Date()
    }

    // Computed properties for tracking
    var unusedCreditsCount: Int {
        credits.filter { !$0.isUsedThisMonth }.count
    }

    var totalCreditsCount: Int {
        credits.count
    }

    var totalMonthlyValue: Double {
        credits.reduce(0) { $0 + $1.amount }
    }

    var remainingValue: Double {
        credits.filter { !$0.isUsedThisMonth }.reduce(0) { $0 + $1.amount }
    }

    var usedValue: Double {
        credits.filter { $0.isUsedThisMonth }.reduce(0) { $0 + $1.amount }
    }
}