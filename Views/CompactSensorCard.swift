import SwiftUI

struct CompactSensorCard: View {
    let title: String
    let temp: Double?
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .font(.system(size: 11, weight: .medium))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let t = temp {
                    Text(String(format: "%.1f°C", t))
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                } else {
                    Text(verbatim: "--")
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                }
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
