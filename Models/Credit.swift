import Foundation
import SwiftData

@Model
final class Credit {
    var id: UUID
    var name: String
    var amount: Double
    var category: String
    var isUsedThisMonth: Bool
    var lastResetDate: Date
    var notes: String
    var creditCard: CreditCard?

    init(name: String, amount: Double, category: String = "Other", notes: String = "", creditCard: CreditCard? = nil) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.category = category
        self.isUsedThisMonth = false
        self.lastResetDate = Date()
        self.notes = notes
        self.creditCard = creditCard
    }

    func toggleUsed() {
        isUsedThisMonth.toggle()
    }

    func resetIfNeeded() {
        let calendar = Calendar.current
        let now = Date()

        // Check if we're in a new month
        if !calendar.isDate(lastResetDate, equalTo: now, toGranularity: .month) {
            isUsedThisMonth = false
            lastResetDate = now
        }
    }
}

// Common credit categories for Amex Gold and other cards
struct CreditCategory {
    static let categories = [
        "Dining",
        "Transportation",
        "Entertainment",
        "Groceries",
        "Travel",
        "Streaming",
        "Shopping",
        "Other"
    ]
}