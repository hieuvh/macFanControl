import SwiftUI
import Combine

struct HeroFanDial: View {
    let fan: FanJSON
    @ObservedObject var viewModel: FanViewModel
    
    @State private var sliderVal: Double = 0.0
    @State private var isEditingSlider: Bool = false
    @State private var sliderPublisher = PassthroughSubject<Double, Never>()
    @State private var animatableSpeed: Double = 0.0
    
    init(fan: FanJSON, viewModel: FanViewModel) {
        self.fan = fan
        self.viewModel = viewModel
        _sliderVal = State(initialValue: Double(fan.targetSpeed))
        _animatableSpeed = State(initialValue: Double(fan.currentSpeed))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and Spinning Fan Icon
            HStack {
                SpinningFanView(currentSpeed: animatableSpeed, maxSpeed: Double(fan.maxSpeed))
                Text(fan.name)
                    .font(.system(size: 18, weight: .black))
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Hero Circular Dial
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(animatableSpeed) / CGFloat(fan.maxSpeed > 0 ? fan.maxSpeed : 6000))
                    .stroke(rpmColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("")
                        .animatableNumber(value: animatableSpeed)
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                    Text("RPM")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 10)
            
            // Speed Controls
            VStack(spacing: 12) {
                // Slider Label
                HStack {
                    Text("Target")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                    if fan.mode == 0 {
                        Text(verbatim: "Auto (\(Int(animatableSpeed)) RPM)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.teal)
                            .contentTransition(.numericText())
                    } else {
                        Text(verbatim: "\(Int(sliderVal)) RPM (\(Int(speedPercentage))%)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.teal)
                            .contentTransition(.numericText())
                    }
                }
                
                // Slider
                Slider(
                    value: $sliderVal,
                    in: Double(fan.minSpeed)...Double(fan.maxSpeed),
                    step: 50.0,
                    onEditingChanged: { editing in
                        isEditingSlider = editing
                        if editing {
                            if fan.mode != 1 {
                                viewModel.changeFanMode(fanId: fan.id, mode: 1)
                            }
                        } else {
                            viewModel.changeFanSpeed(fanId: fan.id, speed: Int(sliderVal))
                        }
                    }
                )
                .accentColor(.teal)
                
                // Presets
                HStack(spacing: 8) {
                    presetButton(title: "Auto", isAuto: true)
                    presetButton(title: "20%", val: getSpeedForPercentage(0.20))
                    presetButton(title: "50%", val: getSpeedForPercentage(0.50))
                    presetButton(title: "80%", val: getSpeedForPercentage(0.80))
                    presetButton(title: "Max", val: Double(fan.maxSpeed))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        // Keep slider synchronized with system status updates if user is not actively dragging it
        .onChange(of: fan.targetSpeed) { newTarget in
            if !isEditingSlider {
                sliderVal = Double(newTarget)
            }
        }
        // Smoothly interpolate the visual RPM number towards the newest hardware snapshot
        .onChange(of: fan.currentSpeed) { newSpeed in
            withAnimation(.linear(duration: 1.5)) {
                animatableSpeed = Double(newSpeed)
            }
        }
        // Publish slider changes while dragging
        .onChange(of: sliderVal) { newValue in
            if isEditingSlider {
                sliderPublisher.send(newValue)
            }
        }
        // Debounce continuous drag events to prevent spamming the SMC helper
        .onReceive(sliderPublisher.debounce(for: .seconds(0.15), scheduler: RunLoop.main)) { debouncedVal in
            viewModel.changeFanSpeed(fanId: fan.id, speed: Int(debouncedVal))
        }
    }
    
    var rpmColor: Color {
        let ratio = Double(animatableSpeed) / Double(fan.maxSpeed > 0 ? fan.maxSpeed : 6000)
        if ratio > 0.75 {
            return .orange
        } else if ratio > 0.4 {
            return .teal
        } else {
            return .blue
        }
    }
    
    var speedPercentage: Double {
        let range = Double(fan.maxSpeed - fan.minSpeed)
        guard range > 0 else { return 0 }
        return ((sliderVal - Double(fan.minSpeed)) / range) * 100.0
    }
    
    func getSpeedForPercentage(_ pct: Double) -> Double {
        let range = Double(fan.maxSpeed - fan.minSpeed)
        return Double(fan.minSpeed) + range * pct
    }
    
    func presetButton(title: String, isAuto: Bool = false, val: Double = 0) -> some View {
        let isActive = isAuto ? (fan.mode == 0) : (fan.mode == 1 && abs(sliderVal - val) <= 2.0)
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isAuto {
                    viewModel.changeFanMode(fanId: fan.id, mode: 0)
                } else {
                    sliderVal = val
                    if fan.mode != 1 {
                        viewModel.changeFanMode(fanId: fan.id, mode: 1)
                    }
                    viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                }
            }
        }) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(isActive ? .teal : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(isActive ? Color.teal.opacity(0.1) : Color.white.opacity(0.02))
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isActive ? Color.teal.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
