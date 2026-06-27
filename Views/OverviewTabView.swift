import SwiftUI

struct OverviewTabView: View {
    @ObservedObject var viewModel: FanViewModel
    @State private var selectedChart: TriggerRule.SensorType?
    
    let fanColumns = [GridItem(.adaptive(minimum: 300), spacing: 24)]
    let sensorColumns = [GridItem(.adaptive(minimum: 150), spacing: 16)]
    
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
                            Text("Helper Authentication Required")
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        Text("You need to authorize Fan Control to adjust fan speeds and read precise hardware sensors.")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        
                        Button(action: { viewModel.authorize() }) {
                            Text("Authorize & Enable Fan Adjustments")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color.orange)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Hero Fans Section
                if !viewModel.fans.isEmpty {
                    LazyHGrid(rows: fanColumns, spacing: 24) {
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
