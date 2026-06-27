import SwiftUI

struct OverviewTabView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let firstFan = viewModel.fans.first {
                    HeroFanDial(fan: firstFan, viewModel: viewModel)
                }
                
                HStack(spacing: 16) {
                    CompactSensorCard(title: "CPU", temp: viewModel.cpuTemp, iconName: "cpu", color: .orange)
                    CompactSensorCard(title: "GPU", temp: viewModel.gpuTemp, iconName: "gauge.with.needle", color: .purple)
                    CompactSensorCard(title: "BATTERY", temp: viewModel.batteryTemp, iconName: "battery.100.bolt", color: .green)
                }
                
                if viewModel.fans.count > 1 {
                    VStack(spacing: 16) {
                        ForEach(viewModel.fans.dropFirst()) { fan in
                            FanControlRow(fan: fan, viewModel: viewModel)
                        }
                    }
                }
            }
            .padding(32)
        }
    }
}
