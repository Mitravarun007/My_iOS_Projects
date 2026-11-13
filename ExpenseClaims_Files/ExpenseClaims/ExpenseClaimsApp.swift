import SwiftUI
import SwiftData

@main
struct ExpenseClaimsApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Bill.self,
            Claim.self,
            ClaimTag.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
