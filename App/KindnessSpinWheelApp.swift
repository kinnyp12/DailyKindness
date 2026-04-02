import SwiftUI

@main
struct KindnessSpinWheelApp: App {

    @StateObject private var controller = SpinWheelController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
                // Handle deep links — kindnesswheel://challenge?id=UUID&bonus=1
                .onOpenURL { url in
                    controller.handleDeepLink(url)
                }
        }
    }
}
