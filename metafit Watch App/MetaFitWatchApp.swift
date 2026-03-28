import SwiftUI
import SwiftData

@main
struct MetaFitWatchApp: App {
    @State private var connectivityManager = WatchConnectivityManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutRecord.self,
            GlassesPhoto.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(sharedModelContainer)
    }
}
