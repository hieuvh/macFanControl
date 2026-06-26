import SwiftUI

// MARK: - Animated Custom Vector Fan View
struct SpinningFanView: View {
    let currentSpeed: Double
    let maxSpeed: Double
    @State private var angle: Double = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Image(systemName: "fan.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.white.opacity(currentSpeed > 0 ? 0.8 : 0.3))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(angle))
                .shadow(color: Color.teal.opacity(currentSpeed > 1000 ? 0.6 : 0), radius: currentSpeed > 3000 ? 6 : 2)
            .onChange(of: timeline.date) { _ in
                // Standardize rotation step to speed
                // 1000 RPM -> ~4 deg per frame
                let delta = max(currentSpeed, 200.0) / 1000.0 * 3.5
                angle += delta
                if angle >= 360 { angle -= 360 }
            }
        }
    }
}
