import SwiftUI

struct OverviewTabView: View {
    @ObservedObject var viewModel: FanViewModel
    @State private var selectedChart: TriggerRule.SensorType?
    
    let fanColumns = [GridItem(.adaptive(minimum: 300), spacing: 24)]
    let sensorColumns = [GridItem(.adaptive(minimum: 150), spacing: 16)]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Fans Section
                if !viewModel.fans.isEmpty {
                    LazyVGrid(columns: fanColumns, spacing: 24) {
                        ForEach(viewModel.fans) { fan in
                            HeroFanDial(fan: fan, viewModel: viewModel)
                        }
                    }
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
                        CompactSensorCard(title: "BATTERY", temp: viewModel.batteryTemp, iconName: "battery.100.bolt", color: .green)
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
