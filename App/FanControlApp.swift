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
                    SpinningFanView(currentSpeed: Double(firstFan.currentSpeed), maxSpeed: Double(firstFan.maxSpeed), size: 14)
                    
                    Text(String(firstFan.currentSpeed))
                        .animatableNumber(value: Double(firstFan.currentSpeed))
                        .font(.system(size: 10, weight: .bold))
                    Image(systemName: "fan.fill")
                        .font(.system(size: 14))
                        .rotationEffect(.degrees(90))

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
