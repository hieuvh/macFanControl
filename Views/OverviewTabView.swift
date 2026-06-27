import SwiftUI

struct OverviewTabView: View {
    @ObservedObject var viewModel: FanViewModel
    @State private var selectedChart: TriggerRule.SensorType?
    
    let fanColumns = [GridItem(.adaptive(minimum: 300), spacing: 24)]
    let sensorColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                
                // Hero Fans Section
                if !viewModel.fans.isEmpty {
                    HStack(spacing: 24) {
                        ForEach(viewModel.fans) { fan in
                            HeroFanDial(fan: fan, viewModel: viewModel)
                                .frame(maxWidth: 400)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Sensors Section
                LazyVGrid(columns: sensorColumns, spacing: 16) {
                    Button(action: { toggleChart(for: .cpu) }) {
                        CompactSensorCard(title: "CPU", temp: viewModel.cpuTemp, iconName: "cpu", color: .orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { toggleChart(for: .gpu) }) {
                        CompactSensorCard(title: "GPU", temp: viewModel.gpuTemp, iconName: "gauge.with.needle", color: .purple)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { toggleChart(for: .battery) }) {
                        CompactSensorCard(title: "Battery", temp: viewModel.batteryTemp, iconName: "battery.100.bolt", color: .green)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Chart Section
                if let sensor = selectedChart {
                    TempHistoryChartView(
                        sensor: sensor,
                        history: viewModel.tempHistory,
                        onClose: {
                            withAnimation {
                                selectedChart = nil
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(32)
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.3), value: selectedChart)
        }
    }
    
    private func toggleChart(for sensor: TriggerRule.SensorType) {
        withAnimation {
            if selectedChart == sensor {
                selectedChart = nil
            } else {
                selectedChart = sensor
            }
        }
    }
}
