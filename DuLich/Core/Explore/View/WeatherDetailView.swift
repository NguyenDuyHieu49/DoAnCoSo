//
//  WeatherDetailView.swift
//  DuLich
//
//  Redesigned with Glassmorphism – iOS light theme
//

import SwiftUI

struct WeatherDetailView: View {
    @ObservedObject var viewModel: WeatherViewModel

    private var isPartlyCloudy: Bool { viewModel.clouds < 50 }

    private var accentColor: Color {
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

    private var backgroundGradient: LinearGradient {
        switch viewModel.weatherMain {
        case "Clear":
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.80, blue: 0.30), Color(red: 0.65, green: 0.85, blue: 1.00)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case "Clouds":
            if isPartlyCloudy {
                return LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.88, blue: 0.55),
                        Color(red: 0.72, green: 0.88, blue: 1.00)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            } else {
                
                return LinearGradient(
                    colors: [
                        Color(red: 0.45, green: 0.52, blue: 0.66),
                        Color(red: 0.62, green: 0.70, blue: 0.82)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            }
        case "Rain", "Drizzle", "Thunderstorm":
            return LinearGradient(
                colors: [Color(red: 0.22, green: 0.40, blue: 0.75), Color(red: 0.55, green: 0.75, blue: 1.00)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case "Snow":
            return LinearGradient(
                colors: [Color(red: 0.72, green: 0.88, blue: 1.00), Color(white: 0.96)],
                startPoint: .top, endPoint: .bottom
            )
        default:
            return LinearGradient(
                colors: [Color(red: 0.52, green: 0.76, blue: 0.96), Color(red: 0.85, green: 0.93, blue: 1.00)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    private var weatherLabel: String {
        switch viewModel.weatherMain {
        case "Clouds":
            return isPartlyCloudy
                ? String(format: NSLocalizedString("weather_partly_cloudy", comment: ""), viewModel.clouds)
                : String(format: NSLocalizedString("weather_heavy_cloud", comment: ""), viewModel.clouds)
        default:
            return viewModel.description.capitalized
        }
    }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            Circle()
                .fill(accentColor.opacity(0.28))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: -80, y: -160)

            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 180, height: 180)
                .blur(radius: 50)
                .offset(x: 100, y: 200)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    VStack(spacing: 6) {
                        Text("weather_today")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.75))
                            .textCase(.uppercase)
                            .tracking(1.0)

                        Image(systemName: viewModel.weatherSymbolName)
                            .font(.system(size: 64, weight: .thin))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .shadow(color: accentColor.opacity(0.40), radius: 12, x: 0, y: 4)
                            .padding(.top, 8)

                        Text(viewModel.temperature)
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

                        Text(weatherLabel)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.80))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        WeatherStatCell(
                            icon: "thermometer.medium",
                            label: "temper_ature",
                            value: viewModel.temperature,
                            color: Color(red: 1.0, green: 0.55, blue: 0.25)
                        )
                        WeatherStatCell(
                            icon: "drop.fill",
                            label: "humid_ity",
                            value: "\(viewModel.humidity)%",
                            color: Color(red: 0.25, green: 0.55, blue: 1.00)
                        )
                        WeatherStatCell(
                            icon: "wind",
                            label: "win_d",
                            value: String(format: "%.1f m/s", viewModel.windSpeed),
                            color: Color(red: 0.15, green: 0.72, blue: 0.80)
                        )
                        WeatherStatCell(
                            icon: "cloud.fill",
                            label: "cloud_y",
                            value: "\(viewModel.clouds)%",
                            // Màu ô mây thay đổi theo mức độ
                            color: viewModel.clouds < 50
                                ? Color(red: 0.95, green: 0.78, blue: 0.20)
                                : Color(red: 0.55, green: 0.62, blue: 0.78)
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
    }
}

private struct WeatherStatCell: View {
    let icon: String
    let label: LocalizedStringKey
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(color.opacity(0.20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .strokeBorder(color.opacity(0.35), lineWidth: 0.7)
                        )
                        .frame(width: 34, height: 34)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(color)
                }

                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.65))
                    .textCase(.uppercase)
                    .tracking(0.4)
            }

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.65), Color.white.opacity(0.20)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
}

#Preview {
    WeatherDetailView(viewModel: WeatherViewModel())
}
