import SwiftUI

struct ContentView: View {

    @EnvironmentObject var controller: SpinWheelController
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SpinWheelView()
                .tabItem {
                    Label("Spin", systemImage: "sparkles")
                }
                .tag(0)

            StreakView()
                .tabItem {
                    Label("Streak", systemImage: "flame.fill")
                }
                .tag(1)
        }
        .sheet(isPresented: $controller.showCompletionSheet) {
            if let challenge = controller.recentlyCompleted {
                CompletionSheet(challenge: challenge)
            }
        }
    }
}
