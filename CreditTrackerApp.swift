import SwiftUI
import SwiftData

@main
struct CreditTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CreditCard.self, Credit.self])
    }
}
