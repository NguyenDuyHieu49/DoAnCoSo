import SwiftUI

struct WeatherDetailView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Thời tiết hôm nay")
                .font(.title)
                .fontWeight(.bold)
            
            Text(viewModel.temperature)
                .font(.system(size: 48))
                .fontWeight(.heavy)
            
            Text(viewModel.description)
                .font(.title3)
                .foregroundColor(.gray)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("🌡️ Nhiệt độ: \(viewModel.temperature)")
                Text("💧 Độ ẩm: \(viewModel.humidity)%")
                Text("🌬️ Gió: \(viewModel.windSpeed) m/s")
                Text("☁️ Mây: \(viewModel.clouds)%")
            }
            .font(.headline)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    WeatherDetailView(viewModel: WeatherViewModel())
}
