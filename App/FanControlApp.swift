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
            if !viewModel.fans.isEmpty {
                let maxSpeed = viewModel.fans.map { $0.currentSpeed }.max() ?? 0
                createMenuIcon(speed: maxSpeed)
            } else {
                Image(systemName: "fan.fill")
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    struct MenuIconCache {
        @MainActor static var cache: [Int: Image] = [:]
    }
    
    @MainActor
    private func createMenuIcon(speed: Int) -> Image {
        let state: Int
        if speed >= 5500 {
            state = 3
        } else if speed >= 3500 {
            state = 2
        } else if speed > 0 {
            state = 1
        } else {
            state = 0
        }
        
        if let cached = MenuIconCache.cache[state] {
            return cached
        }
        
        let view = HStack(spacing: 2) {
            Image(systemName: "fan.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            VStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(state >= 3 ? Color.red : Color.gray.opacity(0.2))
                    .frame(width: 4, height: 4)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(state >= 2 ? Color.yellow : Color.gray.opacity(0.2))
                    .frame(width: 4, height: 4)

                RoundedRectangle(cornerRadius: 4)
                    .fill(state >= 1 ? Color.green : Color.gray.opacity(0.2))
                    .frame(width: 4, height: 4)
            }
            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        
        if let nsImage = renderer.nsImage {
            let img = Image(nsImage: nsImage)
            MenuIconCache.cache[state] = img
            return img
        }
        
        return Image(systemName: "fan.fill")
    }
}
