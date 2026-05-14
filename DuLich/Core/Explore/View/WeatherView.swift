//
//  WeatherView.swift
//  DuLich
//
//  Redesigned with Glassmorphism – iOS light theme
//

import SwiftUI

struct MiniWeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel

    private var accentColor: Color {
        switch viewModel.weatherMain {
        case "Clear":                           return Color(red: 1.0, green: 0.72, blue: 0.05)
        case "Clouds":                          return Color(white: 0.55)
        case "Rain", "Drizzle", "Thunderstorm": return Color(red: 0.25, green: 0.50, blue: 0.95)
        case "Snow":                            return Color(red: 0.55, green: 0.78, blue: 1.00)
        default:                                return Color(red: 0.95, green: 0.55, blue: 0.15)
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: viewModel.weatherSymbolName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(accentColor)

            Text(viewModel.temperature)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(Color(white: 0.10))

            Text(viewModel.description.capitalized)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Color(white: 0.40))
                .lineLimit(1)
        }
        .frame(width: 150, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(accentColor.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.80),
                                    accentColor.opacity(0.30)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.9
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.55), radius: 2, x: 0, y: -1)
        )
        .onTapGesture {
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(red: 0.55, green: 0.78, blue: 0.95), Color(red: 0.85, green: 0.93, blue: 1.0)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()

        HStack(spacing: 12) {
            let vm1 = WeatherViewModel()
            let _ = { vm1.cityName = "Hà Nội"; vm1.temperature = "34°C"; vm1.description = "trời nắng"; vm1.humidity = 58; vm1.windSpeed = 1.2 }()
            MiniWeatherCard(viewModel: vm1)

            let vm2 = WeatherViewModel()
            let _ = { vm2.cityName = "Đà Lạt"; vm2.temperature = "22°C"; vm2.description = "có mây"; vm2.humidity = 72; vm2.windSpeed = 2.5 }()
            MiniWeatherCard(viewModel: vm2)
        }
    }
}
