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
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(fan.name).fontWeight(.bold)
                            Spacer()
                            Button(fan.mode == 1 ? "Manual" : "Auto") {
                                let newMode = fan.mode == 1 ? 0 : 1
                                viewModel.changeFanMode(fanId: fan.id, mode: newMode)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(fan.currentSpeed) },
                                set: { newValue in
                                    viewModel.changeFanSpeed(fanId: fan.id, speed: Int(newValue))
                                }
                            ),
                            in: Double(fan.minSpeed)...Double(fan.maxSpeed),
                            step: 100.0
                        )
                        .disabled(fan.mode == 0) // Disabled if in Auto mode
                        
                        Text("\(fan.currentSpeed) RPM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Bottom Section: Actions
            VStack(spacing: 8) {
                Button("Open Fan Control Center") {
                    openMainWindow()
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("Reset All to Auto") {
                    viewModel.resetAll()
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.red)
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
