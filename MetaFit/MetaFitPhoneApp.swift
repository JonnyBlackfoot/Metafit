import SwiftUI

@main
struct MetaFitPhoneApp: App {
    @State private var connectivityManager = WatchConnectivityManager.shared
    @State private var glassesBridge = GlassesBridgeService.shared

    var body: some Scene {
        WindowGroup {
            GlassesConnectionView()
                .onOpenURL { url in
                    glassesBridge.handleCallback(url: url)
                }
        }
    }
}
