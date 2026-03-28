import SwiftUI

@main
struct MetaFitPhoneApp: App {
    private let connectivityManager = WatchConnectivityManager.shared
    private let glassesBridge = GlassesBridgeService.shared

    var body: some Scene {
        WindowGroup {
            GlassesConnectionView()
                .onOpenURL { url in
                    glassesBridge.handleCallback(url: url)
                }
        }
    }
}
