import SwiftUI

@main
struct KindnessSpinWheelApp: App {

    @StateObject private var spinController = SpinWheelController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spinController)
        }
    }
}
