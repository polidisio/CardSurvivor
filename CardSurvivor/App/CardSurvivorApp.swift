import SwiftUI

@main
struct CardSurvivorApp: App {
    init() {
        // Start playing menu music
        MusicManager.shared.playMenu()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
