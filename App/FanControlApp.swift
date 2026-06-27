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
                Text("\(firstFan.currentSpeed) RPM")
            } else {
                Image(systemName: "fan.fill")
                Text("--")
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    @MainActor
    private func createMenuIcon(speed: Int) -> Image {
        let view = HStack(spacing: 4) {
            Image(systemName: "fan.fill")
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(speed > 0 ? Color.white : Color.gray.opacity(0.3))
                    .frame(width: 3, height: 14)
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(speed >= 3000 ? Color.yellow : Color.gray.opacity(0.3))
                    .frame(width: 3, height: 14)
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(speed >= 5000 ? Color.red : Color.gray.opacity(0.3))
                    .frame(width: 3, height: 14)
            }
        }
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = NSApplication.shared.windows.first?.backingScaleFactor ?? 2.0
        
        if let nsImage = renderer.nsImage {
            return Image(nsImage: nsImage)
        }
        
        return Image(systemName: "fan.fill")
    }
}
