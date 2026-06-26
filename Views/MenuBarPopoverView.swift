import SwiftUI

struct MenuBarPopoverView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Top Section: Telemetry
            HStack(spacing: 10) {
                TelemetryCard(temp: viewModel.cpuTemp, label: "CPU")
                TelemetryCard(temp: viewModel.gpuTemp, label: "GPU")
                TelemetryCard(temp: viewModel.batteryTemp, label: "BATT")
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
                    for fan in viewModel.fans {
                        let range = Double(fan.maxSpeed - fan.minSpeed)
                        let val = Double(fan.minSpeed) + range * 0.5
                        if fan.mode != 1 {
                            viewModel.changeFanMode(fanId: fan.id, mode: 1)
                        }
                        viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                    }
                }) {
                    VStack {
                        Image(systemName: "link")
                            .font(.system(size: 14))
                        Text("Sync 50%").font(.system(size: 8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .help("Sync All Fans to 50%")
                
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
                Button(action: { NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil) }) {
                    VStack {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14))
                        Text("Settings").font(.system(size: 8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .help("Open Settings")
                
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
                Text("--")
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                SpinningFanView(currentSpeed: Double(fan.currentSpeed), maxSpeed: Double(fan.maxSpeed), size: 24)
                Text(fan.name).fontWeight(.bold)
                Spacer()
                Text("\(fan.currentSpeed) RPM")
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
        }
        .onChange(of: fan.targetSpeed) { newTarget in
            if !isEditingSlider {
                sliderVal = Double(newTarget)
            }
        }
    }
    
    func getSpeedForPercentage(_ pct: Double) -> Double {
        let range = Double(fan.maxSpeed - fan.minSpeed)
        return Double(fan.minSpeed) + range * pct
    }
    
    func presetButton(title: String, isAuto: Bool = false, val: Double = 0) -> some View {
        let isActive = isAuto ? (fan.mode == 0) : (fan.mode == 1 && sliderVal == val)
        
        return Button(action: {
            if isAuto {
                viewModel.changeFanMode(fanId: fan.id, mode: 0)
            } else {
                sliderVal = val
                if fan.mode != 1 {
                    viewModel.changeFanMode(fanId: fan.id, mode: 1)
                }
                viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
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
