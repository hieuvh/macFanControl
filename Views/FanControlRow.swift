import SwiftUI
import Combine

// MARK: - Individual Fan Control Row
struct FanControlRow: View {
    let fan: FanJSON
    @ObservedObject var viewModel: FanViewModel
    
    @State private var sliderVal: Double = 0.0
    @State private var isEditingSlider: Bool = false
    @State private var sliderPublisher = PassthroughSubject<Double, Never>()
    
    init(fan: FanJSON, viewModel: FanViewModel) {
        self.fan = fan
        self.viewModel = viewModel
        // Initial setup of state
        _sliderVal = State(initialValue: Double(fan.targetSpeed))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Info
            HStack(spacing: 16) {
                SpinningFanView(currentSpeed: Double(fan.currentSpeed), maxSpeed: Double(fan.maxSpeed))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(fan.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Text("\(fan.currentSpeed)")
                            .font(.system(size: 26, weight: .black, design: .monospaced))
                            .foregroundColor(rpmColor)
                        Text("RPM")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.gray)
                            .offset(y: 4)
                    }
                }
                
                Spacer()
            }
            
            // Speed Controls
            VStack(spacing: 12) {
                // Slider Label
                HStack {
                    Text("Target Speed")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Spacer()
                    if fan.mode == 0 {
                        Text("Auto (\(Int(fan.currentSpeed)) RPM)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.teal)
                            .contentTransition(.numericText())
                    } else {
                        Text("\(Int(sliderVal)) RPM (\(Int(speedPercentage))%)")
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
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color.white.opacity(0.02))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        // Keep slider synchronized with system status updates if user is not actively dragging it
        .onChange(of: fan.targetSpeed) { newTarget in
            if !isEditingSlider {
                sliderVal = Double(newTarget)
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
        let ratio = Double(fan.currentSpeed) / Double(fan.maxSpeed > 0 ? fan.maxSpeed : 6000)
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
