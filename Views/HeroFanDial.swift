import SwiftUI

struct HeroFanDial: View {
    let fan: FanJSON
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(fan.currentSpeed) / CGFloat(fan.maxSpeed > 0 ? fan.maxSpeed : 6000))
                    .stroke(Color.teal, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: fan.currentSpeed)
                
                VStack(spacing: 4) {
                    Text(String(fan.currentSpeed))
                        .animatableNumber(value: Double(fan.currentSpeed))
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                    Text("RPM")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Text(fan.name)
                .font(.system(size: 16, weight: .bold))
            
            // Slider
            Slider(
                value: Binding(
                    get: { Double(fan.targetSpeed) },
                    set: { val in
                        if fan.mode != 1 {
                            viewModel.changeFanMode(fanId: fan.id, mode: 1)
                        }
                        viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                    }
                ),
                in: Double(fan.minSpeed)...Double(fan.maxSpeed)
            )
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
