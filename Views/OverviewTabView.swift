import SwiftUI

struct OverviewTabView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Fans Section
                if !viewModel.fans.isEmpty {
                    HStack(spacing: 24) {
                        ForEach(viewModel.fans) { fan in
                            HeroFanDial(fan: fan, viewModel: viewModel)
                        }
                    }
                }
                
                // Sensors Section
                HStack(spacing: 16) {
                    CompactSensorCard(title: "CPU", temp: viewModel.cpuTemp, iconName: "cpu", color: .orange)
                    CompactSensorCard(title: "GPU", temp: viewModel.gpuTemp, iconName: "gauge.with.needle", color: .purple)
                    CompactSensorCard(title: "BATTERY", temp: viewModel.batteryTemp, iconName: "battery.100.bolt", color: .green)
                }
            }
            .padding(32)
        }
    }
}
