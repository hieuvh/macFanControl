import SwiftUI

struct OverviewTabView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Fans Section
                if !viewModel.fans.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(viewModel.fans) { fan in
                                HeroFanDial(fan: fan, viewModel: viewModel)
                                    .frame(minWidth: 320, maxWidth: 450)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                }
                
                // Sensors Section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        CompactSensorCard(title: "CPU", temp: viewModel.cpuTemp, iconName: "cpu", color: .orange)
                            .frame(minWidth: 160)
                        CompactSensorCard(title: "GPU", temp: viewModel.gpuTemp, iconName: "gauge.with.needle", color: .purple)
                            .frame(minWidth: 160)
                        CompactSensorCard(title: "BATTERY", temp: viewModel.batteryTemp, iconName: "battery.100.bolt", color: .green)
                            .frame(minWidth: 160)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                }
            }
            .padding(32)
        }
    }
}
