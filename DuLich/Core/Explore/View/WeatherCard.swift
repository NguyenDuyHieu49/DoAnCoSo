//
//  WeatherCard.swift
//  DuLich
//
//  Redesigned with Glassmorphism – iOS light theme
//

import SwiftUI

struct WeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var animate = false

    private var isPartlyCloudy: Bool { viewModel.clouds < 50 }

    private var backgroundGradient: LinearGradient {
        switch viewModel.weatherMain {
        case "Clear":
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.88, blue: 0.35).opacity(0.38),
                    Color(red: 1.0, green: 0.65, blue: 0.12).opacity(0.22)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case "Clouds":
            if isPartlyCloudy {
                return LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.93, blue: 0.72).opacity(0.48),
                        Color(red: 0.85, green: 0.92, blue: 1.00).opacity(0.30)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            } else {
                return LinearGradient(
                    colors: [
                        Color(red: 0.58, green: 0.66, blue: 0.80).opacity(0.48),
                        Color(red: 0.46, green: 0.54, blue: 0.70).opacity(0.30)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            }
        case "Rain", "Drizzle", "Thunderstorm":
            return LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.50, blue: 0.90).opacity(0.32),
                    Color(red: 0.10, green: 0.30, blue: 0.70).opacity(0.18)
                ],
                startPoint: .top, endPoint: .bottom
            )
        case "Snow":
            return LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.92, blue: 1.00).opacity(0.42),
                    Color(red: 0.65, green: 0.82, blue: 1.00).opacity(0.24)
                ],
                startPoint: .top, endPoint: .bottom
            )
        case "Mist", "Fog", "Haze", "Smoke", "Dust":
            return LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.88, blue: 0.92).opacity(0.42),
                    Color(red: 0.78, green: 0.82, blue: 0.88).opacity(0.26)
                ],
                startPoint: .top, endPoint: .bottom
            )
        default:
            return LinearGradient(
                colors: [Color.white.opacity(0.38), Color.white.opacity(0.18)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    private var borderColor: Color {
        switch viewModel.weatherMain {
        case "Clear":
            return Color(red: 1.0, green: 0.80, blue: 0.20).opacity(0.55)
        case "Clouds":
            return isPartlyCloudy
                ? Color(red: 0.98, green: 0.88, blue: 0.50).opacity(0.50)
                : Color(red: 0.55, green: 0.62, blue: 0.78).opacity(0.45)
        case "Rain", "Drizzle", "Thunderstorm":
            return Color(red: 0.40, green: 0.60, blue: 1.00).opacity(0.45)
        case "Snow":
            return Color(red: 0.70, green: 0.88, blue: 1.00).opacity(0.55)
        default:
            return Color.white.opacity(0.40)
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundGradient)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.75),
                                    borderColor,
                                    Color.white.opacity(0.30)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                )
                .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
                .shadow(color: Color.white.opacity(0.60), radius: 2,  x: 0, y: -1)

            Group {
                switch viewModel.weatherMain {
                case "Rain", "Drizzle", "Thunderstorm":
                    RainEffect().allowsHitTesting(false).opacity(0.85)
                case "Snow":
                    SnowEffect().allowsHitTesting(false)
                case "Clear":
                    SunRaysEffect().allowsHitTesting(false).opacity(0.55)
                case "Clouds":
                    if !isPartlyCloudy {
                        OvercastEffect().allowsHitTesting(false)
                    }
                default:
                    EmptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle().strokeBorder(Color.white.opacity(0.60), lineWidth: 0.8)
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                    Image(systemName: viewModel.weatherSymbolName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(symbolColor)
                        .scaleEffect(animate ? 1.06 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                            value: animate
                        )
                }
                .padding(.leading, 14)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.cityName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(white: 0.10))

                    Text(weatherLabel)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(Color(white: 0.35))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text(viewModel.temperature)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color(white: 0.10))

                    HStack(spacing: 6) {
                        Label("\(viewModel.humidity)%", systemImage: "drop.fill")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.9))

                        Text("·")
                            .font(.system(size: 10))
                            .foregroundColor(Color(white: 0.55))

                        Label(String(format: "%.1f m/s", viewModel.windSpeed), systemImage: "wind")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color(white: 0.40))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.55), lineWidth: 0.6))
                    )
                }
                .padding(.trailing, 14)
            }
            .padding(.vertical, 14)
        }
        .frame(height: 100)
        .padding(.horizontal, 16)
        .onAppear { animate = true }
    }

    private var weatherLabel: String {
        switch viewModel.weatherMain {
        case "Clouds":
            return isPartlyCloudy
                ? "Nắng có mây (\(viewModel.clouds)%)"
                : "Nhiều mây, dễ mưa (\(viewModel.clouds)%)"
        default:
            return viewModel.description.capitalized
        }
    }

    private var symbolColor: Color {
        switch viewModel.weatherMain {
        case "Clear":
            return Color(red: 1.0, green: 0.72, blue: 0.05)
        case "Clouds":
            return isPartlyCloudy
                ? Color(red: 0.95, green: 0.78, blue: 0.20)
                : Color(red: 0.55, green: 0.62, blue: 0.75)
        case "Rain", "Drizzle", "Thunderstorm":
            return Color(red: 0.25, green: 0.50, blue: 0.95)
        case "Snow":
            return Color(red: 0.55, green: 0.78, blue: 1.00)
        default:
            return Color(red: 0.95, green: 0.55, blue: 0.15)
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

        VStack(spacing: 12) {
            let vm1 = WeatherViewModel()
            let _ = { vm1.cityName = "Hà Nội"; vm1.temperature = "34°C"; vm1.description = "trời nắng"; vm1.humidity = 58; vm1.windSpeed = 1.2; vm1.clouds = 0 }()
            WeatherCard(viewModel: vm1)

            let vm2 = WeatherViewModel()
            let _ = { vm2.cityName = "Đà Nẵng"; vm2.temperature = "29°C"; vm2.description = "nắng có mây"; vm2.humidity = 65; vm2.windSpeed = 2.0; vm2.clouds = 35 }()
            WeatherCard(viewModel: vm2)

            let vm3 = WeatherViewModel()
            let _ = { vm3.cityName = "Hải Phòng"; vm3.temperature = "26°C"; vm3.description = "nhiều mây"; vm3.humidity = 82; vm3.windSpeed = 3.5; vm3.clouds = 78 }()
            WeatherCard(viewModel: vm3)

            let vm4 = WeatherViewModel()
            let _ = { vm4.cityName = "Hội An"; vm4.temperature = "24°C"; vm4.description = "mưa nhẹ"; vm4.humidity = 90; vm4.windSpeed = 2.8; vm4.clouds = 95 }()
            WeatherCard(viewModel: vm4)
        }
        .padding(.top, 40)
    }
}
