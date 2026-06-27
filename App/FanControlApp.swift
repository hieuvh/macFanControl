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
                if let firstFan = viewModel.fans.first {
                    Image(systemName: "fan.fill")
                        .font(.system(size: 14))
                        .rotationEffect(.degrees(Double(firstFan.currentSpeed) / Double(firstFan.maxSpeed) * 360))

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
