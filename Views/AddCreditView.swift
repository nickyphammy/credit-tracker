import SwiftUI
import SwiftData

struct AddCreditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var card: CreditCard

    @State private var name = ""
    @State private var amount = ""
    @State private var category = "Other"
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Credit Name", text: $name)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Credit Details")
                }

                Section {
                    Picker("Category", selection: $category) {
                        ForEach(CreditCategory.categories, id: \.self) { cat in
                            HStack {
                                Image(systemName: categoryIcon(for: cat))
                                Text(cat)
                            }
                            .tag(cat)
                        }
                    }
                } header: {
                    Text("Category")
                }

                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Additional Notes")
                } footer: {
                    Text("e.g., Which merchants accept this credit")
                }
            }
            .navigationTitle("Add Credit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCredit()
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }

    private func saveCredit() {
        guard let amountValue = Double(amount) else { return }

        let credit = Credit(
            name: name,
            amount: amountValue,
            category: category,
            notes: notes
        )

        card.credits.append(credit)
        modelContext.insert(credit)

        dismiss()
    }

    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Dining": return "fork.knife"
        case "Transportation": return "car.fill"
        case "Entertainment": return "ticket.fill"
        case "Groceries": return "cart.fill"
        case "Travel": return "airplane"
        case "Streaming": return "tv.fill"
        case "Shopping": return "bag.fill"
        default: return "star.fill"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CreditCard.self, Credit.self, configurations: config)

    let card = CreditCard(name: "Amex Gold", issuer: "American Express")
    container.mainContext.insert(card)

    return AddCreditView(card: card)
        .modelContainer(container)
}
