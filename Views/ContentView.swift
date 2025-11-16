import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var creditCards: [CreditCard]
    @State private var showingAddCard = false

    var body: some View {
        NavigationStack {
            if creditCards.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(creditCards) { card in
                        NavigationLink(destination: CardDetailView(card: card)) {
                            CardRowView(card: card)
                        }
                    }
                    .onDelete(perform: deleteCards)
                }
            }
        }
        .navigationTitle("Credit Cards")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddCard = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                if !creditCards.isEmpty {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddCardView()
        }
        .onAppear {
            // Auto-reset credits on app launch
            resetCreditsIfNeeded()

            // Add sample Amex Gold card if no cards exist
            if creditCards.isEmpty {
                addSampleAmexGold()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Credit Cards")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap + to add your first credit card")
                .foregroundColor(.secondary)

            Button(action: { showingAddCard = true }) {
                Label("Add Credit Card", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteCards(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(creditCards[index])
        }
    }

    private func resetCreditsIfNeeded() {
        for card in creditCards {
            for credit in card.credits {
                credit.resetIfNeeded()
            }
        }
    }

    private func addSampleAmexGold() {
        let amexGold = CreditCard(name: "Amex Gold", issuer: "American Express")
        modelContext.insert(amexGold)

        // Amex Gold credits - Based on 2025 benefits
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

        amexGold.credits.append(uberCredit)
        amexGold.credits.append(diningCredit)
        amexGold.credits.append(dunkinCredit)
        modelContext.insert(uberCredit)
        modelContext.insert(diningCredit)
        modelContext.insert(dunkinCredit)
    }
}

struct CardRowView: View {
    let card: CreditCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(card.name)
                    .font(.headline)
                Spacer()
                if card.unusedCreditsCount > 0 {
                    Text("\(card.unusedCreditsCount) unused")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }

            Text(card.issuer)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(card.remainingValue, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Total Monthly")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(card.totalMonthlyValue, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CreditCard.self, Credit.self])
}