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
                Image(systemName: "fan.fill")
                if let firstFan = viewModel.fans.first {
                    Text(String(firstFan.currentSpeed))
                        .animatableNumber(value: Double(firstFan.currentSpeed))
                        .font(.system(size: 10, weight: .bold))
                } else {
                    Text("--")
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
        }
        .menuBarExtraStyle(.window)
    }
}
