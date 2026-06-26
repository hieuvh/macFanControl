import SwiftUI
import AppKit

@main
struct FanControlApp: App {
    @StateObject private var viewModel = FanViewModel()
    
    init() {
        // Force the app to act as a normal foreground application with dock icon
        NSApplication.shared.setActivationPolicy(.regular)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        
        MenuBarExtra {
            MenuBarPopoverView(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "wind")
                // if let firstFan = viewModel.fans.first {
                //     Text("\(firstFan.currentSpeed) RPM")
                // } else {
                //     Text("Fan Control")
                // }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
