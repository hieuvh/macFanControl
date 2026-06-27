import SwiftUI

struct SettingsTabView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.system(size: 28, weight: .black))
                
                if !viewModel.isAuthorized {
                    // Privilege setup card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Helper Authentication Required")
                            .font(.system(size: 16, weight: .bold))
                        
                        Button(action: { viewModel.authorize() }) {
                            Text("Authorize & Enable Fan Adjustments")
                                .font(.system(size: 13, weight: .bold))
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Global Controls
                VStack(spacing: 16) {
                    Toggle("Sync All Fans Together", isOn: $viewModel.linkedFans)
                        .toggleStyle(SwitchToggleStyle(tint: .teal))
                    
                    Button(action: { viewModel.resetAll() }) {
                        Text("Reset All to Auto")
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            .padding(32)
        }
    }
}
