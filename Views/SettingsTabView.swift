import SwiftUI

struct SettingsTabView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.system(size: 20, weight: .semibold))
                
                if !viewModel.isAuthorized {
                    AuthorizationRequiredCard(viewModel: viewModel)
                }
                
                // Global Controls
                VStack(alignment: .leading, spacing: 16) {
                    Text("Global controls")
                        .font(.system(size: 13, weight: .semibold))
                        
                    Toggle("Link fans", isOn: $viewModel.linkedFans)
                        .toggleStyle(SwitchToggleStyle(tint: .teal))
                    
                    Toggle("Launch at startup", isOn: $viewModel.launchAtStartup)
                        .toggleStyle(SwitchToggleStyle(tint: .teal))
                    
                    Button(action: { viewModel.resetAll() }) {
                        Text("Reset to auto")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                
                // Version Info
                HStack {
                    Spacer()
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "3.0") (Build \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                }
                .padding(.top, 16)
            }
            .padding(32)
        }
    }
}
