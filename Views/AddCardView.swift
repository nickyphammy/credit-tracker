import SwiftUI
import SwiftData

struct AddCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var issuer = ""

    // Common card presets
    let cardPresets = [
        ("Amex Gold", "American Express"),
        ("Amex Platinum", "American Express"),
        ("Chase Sapphire Reserve", "Chase"),
        ("Custom", "")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Card Preset", selection: Binding(
                        get: {
                            if let index = cardPresets.firstIndex(where: { $0.0 == name && $0.1 == issuer }) {
                                return index
                            }
                            return cardPresets.count - 1
                        },
                        set: { index in
                            name = cardPresets[index].0
                            issuer = cardPresets[index].1
                        }
                    )) {
                        ForEach(0..<cardPresets.count, id: \.self) { index in
                            Text(cardPresets[index].0).tag(index)
                        }
                    }
                } header: {
                    Text("Quick Select")
                }

                Section {
                    TextField("Card Name", text: $name)
                    TextField("Issuer", text: $issuer)
                } header: {
                    Text("Card Details")
                } footer: {
                    Text("Enter the name and issuer of your credit card")
                }
            }
            .navigationTitle("Add Credit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCard()
                    }
                    .disabled(name.isEmpty || issuer.isEmpty)
                }
            }
        }
    }

    private func saveCard() {
        let card = CreditCard(name: name, issuer: issuer)
        modelContext.insert(card)

        // Add default credits for Amex Gold - Based on 2025 benefits
        if name == "Amex Gold" {
            let uberCredit = Credit(
                name: "Uber Cash",
                amount: 10.00,
                category: "Transportation",
                notes: "$10/month for Uber rides, Uber Eats, and Uber groceries"
            )
            let diningCredit = Credit(
                name: "Dining Credit",
                amount: 10.00,
                category: "Dining",
                notes: "Grubhub, Cheesecake Factory, Goldbelly, Wine.com, Five Guys"
            )
            let dunkinCredit = Credit(
                name: "Dunkin' Credit",
                amount: 7.00,
                category: "Dining",
                notes: "$7/month for eligible U.S. Dunkin' purchases"
            )

            card.credits.append(uberCredit)
            card.credits.append(diningCredit)
            card.credits.append(dunkinCredit)
            modelContext.insert(uberCredit)
            modelContext.insert(diningCredit)
            modelContext.insert(dunkinCredit)
        }

        dismiss()
    }
}

#Preview {
    AddCardView()
        .modelContainer(for: [CreditCard.self, Credit.self])
}
