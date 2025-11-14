import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Bindable var card: CreditCard
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddCredit = false

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(card.issuer)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)

                // Summary stats
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Credits")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(card.totalCreditsCount)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Monthly Value")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(card.totalMonthlyValue, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Used")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(card.usedValue, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(card.remainingValue, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section {
                if card.credits.isEmpty {
                    Text("No credits added yet")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(card.credits) { credit in
                        CreditRowView(credit: credit)
                    }
                    .onDelete(perform: deleteCredits)
                }
            } header: {
                Text("Credits")
            }
        }
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddCredit = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCredit) {
            AddCreditView(card: card)
        }
    }

    private func deleteCredits(at offsets: IndexSet) {
        for index in offsets {
            let credit = card.credits[index]
            card.credits.remove(at: index)
            modelContext.delete(credit)
        }
    }
}

struct CreditRowView: View {
    @Bindable var credit: Credit

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(credit.name)
                    .font(.headline)

                HStack {
                    Image(systemName: categoryIcon(for: credit.category))
                        .font(.caption)
                    Text(credit.category)
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                if !credit.notes.isEmpty {
                    Text(credit.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(credit.amount, specifier: "%.2f")")
                    .font(.headline)

                Button(action: {
                    credit.toggleUsed()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: credit.isUsedThisMonth ? "checkmark.circle.fill" : "circle")
                        Text(credit.isUsedThisMonth ? "Used" : "Unused")
                    }
                    .font(.caption)
                    .foregroundColor(credit.isUsedThisMonth ? .green : .orange)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
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
    let credit1 = Credit(name: "Uber Credit", amount: 10.0, category: "Transportation")
    let credit2 = Credit(name: "Dining Credit", amount: 10.0, category: "Dining")

    card.credits.append(credit1)
    card.credits.append(credit2)
    container.mainContext.insert(card)

    return NavigationStack {
        CardDetailView(card: card)
    }
    .modelContainer(container)
}
