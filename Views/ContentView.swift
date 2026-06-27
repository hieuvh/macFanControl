import SwiftUI
import AppKit

enum DashboardTab {
    case overview
    case rules
    case settings
}

struct ContentView: View {
    @ObservedObject var viewModel: FanViewModel
    
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("fan control")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 20)
                
                SidebarButton(title: "Overview", icon: "square.grid.2x2.fill", isSelected: viewModel.selectedTab == .overview) {
                    viewModel.selectedTab = .overview
                }
                
                SidebarButton(title: "Rules", icon: "bolt.fill", isSelected: viewModel.selectedTab == .rules) {
                    viewModel.selectedTab = .rules
                }
                
                SidebarButton(title: "Settings", icon: "gearshape.fill", isSelected: viewModel.selectedTab == .settings) {
                    viewModel.selectedTab = .settings
                }
                
                Spacer()
            }
            .padding(24)
            .frame(width: 220)
            .background(Color.black.opacity(0.3))
            .layoutPriority(1)
            
            // Main Content Area
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).edgesIgnoringSafeArea(.all)
                
                switch viewModel.selectedTab {
                case .overview:
                    OverviewTabView(viewModel: viewModel)
                case .rules:
                    ScrollView {
                        RulesEngineView(viewModel: viewModel)
                            .padding(32)
                    }
                case .settings:
                    SettingsTabView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 600, idealWidth: 800, minHeight: 500, idealHeight: 650)
        .background(Color(red: 0.04, green: 0.04, blue: 0.05))
        .background(WindowAccessor { window in
            window.identifier = NSUserInterfaceItemIdentifier("main-window")
            window.delegate = MainWindowDelegate.shared
        })
    }
}

struct SidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.teal.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.teal.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Window Accessor
struct WindowAccessor: NSViewRepresentable {
    var onWindowBind: (NSWindow) -> Void
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window { onWindowBind(window) }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

class MainWindowDelegate: NSObject, NSWindowDelegate {
    static let shared = MainWindowDelegate()
}
