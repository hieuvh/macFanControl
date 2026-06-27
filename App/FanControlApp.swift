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
            if let firstFan = viewModel.fans.first {
                createMenuIcon(speed: firstFan.currentSpeed)
            } else {
                Image(systemName: "fan.fill")
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    @MainActor
    private func createMenuIcon(speed: Int) -> Image {
        let view = HStack(spacing: 2) {
            Image(systemName: "fan.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            VStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(speed >= 5500 ? Color.red : Color.gray.opacity(0.2))
                    .frame(width: 4, height: 4)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(speed >= 3500 ? Color.yellow : Color.gray.opacity(0.2))
                    .frame(width: 4, height: 4)

                RoundedRectangle(cornerRadius: 4)
                    .fill(speed > 0 ? Color.green : Color.gray.opacity(0.2))
                    .frame(width: 4, height: 4)
            }
            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = NSApplication.shared.windows.first?.backingScaleFactor ?? 2.0
        
        if let nsImage = renderer.nsImage {
            return Image(nsImage: nsImage)
        }
        
        return Image(systemName: "fan.fill")
    }
}
