import SwiftUI

struct AuthorizationRequiredCard: View {
    @ObservedObject var viewModel: FanViewModel
    var compact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 10 : 16) {
            HStack(spacing: compact ? 8 : 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: compact ? 14 : 20))
                Text("Authorization required")
                    .font(.system(size: compact ? 12 : 14, weight: .semibold))
            }
            
            Text(compact ? "Authorize to manage fans and read sensors." : "Authorize to manage fan speeds and read hardware sensors.")
                .font(.system(size: compact ? 11 : 12))
                .foregroundColor(.gray)
            
            Button(action: { viewModel.authorize() }) {
                Text("Authorize")
                    .font(.system(size: compact ? 11 : 12, weight: .medium))
                    .padding(.vertical, compact ? 6 : 10)
                    .padding(.horizontal, compact ? 12 : 16)
                    .background(Color.orange)
                    .foregroundColor(.black)
                    .cornerRadius(compact ? 6 : 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(compact ? 12 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(compact ? 8 : 12)
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 8 : 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}
