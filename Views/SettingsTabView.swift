import SwiftUI

struct SettingsTabView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.system(size: 20, weight: .semibold))
                
                if !viewModel.isAuthorized {
                    // Privilege setup card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 20))
                            Text("Authorization required")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        Text("Authorize to manage fan speeds and read hardware sensors.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Button(action: { viewModel.authorize() }) {
                            Text("Authorize")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color.orange)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Global Controls
                VStack(alignment: .leading, spacing: 16) {
                    Text("Global controls")
                        .font(.system(size: 13, weight: .semibold))
                        
                    Toggle("Link fans", isOn: $viewModel.linkedFans)
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
            }
            .padding(32)
        }
    }
}
