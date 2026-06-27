import SwiftUI

struct MenuBarPopoverView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Top Section: Telemetry
            HStack(spacing: 10) {
                TelemetryCard(temp: viewModel.cpuTemp, label: "CPU")
                TelemetryCard(temp: viewModel.gpuTemp, label: "GPU")
                TelemetryCard(temp: viewModel.batteryTemp, label: "BATTERY")
            }
            .padding(.horizontal)
            .padding(.top, 15)
            
            // Middle Section: Fans
            VStack(spacing: 12) {
                ForEach(viewModel.fans) { fan in
                    MenuBarFanRow(fan: fan, viewModel: viewModel)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Bottom Section: Actions
            HStack(spacing: 20) {
                // Open App
                Button(action: { openMainWindow() }) {
                    VStack {
                        Image(systemName: "macwindow")
                            .font(.system(size: 14))
                        Text("App").font(.system(size: 8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .help("Open Fan Control Center")
                
                // Sync All Fans
                Button(action: { 
                    viewModel.linkedFans.toggle()
                }) {
                    VStack {
                        Image(systemName: "link")
                            .font(.system(size: 14))
                            .foregroundColor(viewModel.linkedFans ? .teal : .primary)
                        Text(viewModel.linkedFans ? "Linked" : "Link Fans").font(.system(size: 8))
                            .foregroundColor(viewModel.linkedFans ? .teal : .primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .help(viewModel.linkedFans ? "Unlink Fans" : "Sync All Fans Together")
                
                // Reset to Auto
                Button(action: { viewModel.resetAll() }) {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14))
                        Text("Auto").font(.system(size: 8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .help("Reset All to Auto")
                
                // Settings
                // Button(action: { NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil) }) {
                //     VStack {
                //         Image(systemName: "gearshape")
                //             .font(.system(size: 14))
                //         Text("Settings").font(.system(size: 8))
                //     }
                // }
                // .buttonStyle(PlainButtonStyle())
                // .help("Open Settings")
                
                // Quit
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    VStack {
                        Image(systemName: "power")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        Text("Quit").font(.system(size: 8)).foregroundColor(.red)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 15)
        }
        .frame(width: 320)
    }
    
    private func openMainWindow() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}

struct TelemetryCard: View {
    var temp: Double?
    var label: String
    
    var body: some View {
        VStack {
            if let t = temp {
                Text(String(format: "%.0f°C", t))
                    .font(.system(size: 20, weight: .bold))
            } else {
                Text(verbatim: "--")
                    .font(.system(size: 20, weight: .bold))
            }
            Text(label)
                .font(.system(size: 10))
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct MenuBarFanRow: View {
    var fan: FanJSON
    @ObservedObject var viewModel: FanViewModel
    
    @State private var sliderVal: Double = 0.0
    @State private var isEditingSlider: Bool = false
    @State private var animatableSpeed: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                SpinningFanView(currentSpeed: animatableSpeed, maxSpeed: Double(fan.maxSpeed), size: 24)
                Text(fan.name).fontWeight(.bold)
                Spacer()
                HStack(spacing: 2) {
                    Text(verbatim: "\(Int(animatableSpeed))")
                        .contentTransition(.numericText())
                    Text("RPM")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 6) {
                presetButton(title: "Auto", isAuto: true)
                presetButton(title: "20%", val: getSpeedForPercentage(0.20))
                presetButton(title: "50%", val: getSpeedForPercentage(0.50))
                presetButton(title: "80%", val: getSpeedForPercentage(0.80))
                presetButton(title: "Max", val: Double(fan.maxSpeed))
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .onAppear {
            sliderVal = Double(fan.targetSpeed)
            animatableSpeed = Double(fan.currentSpeed)
        }
        .onChange(of: fan.targetSpeed) { newTarget in
            if !isEditingSlider {
                sliderVal = Double(newTarget)
            }
        }
        .onChange(of: fan.currentSpeed) { newSpeed in
            withAnimation(.linear(duration: 1.5)) {
                animatableSpeed = Double(newSpeed)
            }
        }
    }
    
    func getSpeedForPercentage(_ pct: Double) -> Double {
        let range = Double(fan.maxSpeed - fan.minSpeed)
        return Double(fan.minSpeed) + range * pct
    }
    
    func presetButton(title: String, isAuto: Bool = false, val: Double = 0) -> some View {
        let isActive = isAuto ? (fan.mode == .automatic) : (fan.mode == .forced && abs(sliderVal - val) <= 2.0)
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isAuto {
                    viewModel.changeFanMode(fanId: fan.id, mode: .automatic)
                } else {
                    sliderVal = val
                    if fan.mode != .forced {
                        viewModel.changeFanMode(fanId: fan.id, mode: .forced)
                    }
                    viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                }
            }
        }) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isActive ? .teal : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(isActive ? Color.teal.opacity(0.15) : Color.white.opacity(0.1))
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
