//
//  WeatherCard.swift
//  DuLich
//
//  Created by Macbook Pro on 3/5/26.
//

import SwiftUI

struct WeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var animate = false

    // Màu nền theo trạng thái
    private var backgroundGradient: LinearGradient {
        switch viewModel.weatherMain {
        case "Clear":
            return LinearGradient(colors: [Color("SunStart", bundle: nil).opacity(0.9), Color("SunEnd", bundle: nil).opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Clouds":
            return LinearGradient(colors: [Color(.systemGray5), Color(.systemGray4)], startPoint: .top, endPoint: .bottom)
        case "Rain", "Drizzle", "Thunderstorm":
            return LinearGradient(colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.05)], startPoint: .top, endPoint: .bottom)
        case "Snow":
            return LinearGradient(colors: [Color.white, Color.blue.opacity(0.08)], startPoint: .top, endPoint: .bottom)
        case "Mist", "Fog", "Haze", "Smoke", "Dust":
            return LinearGradient(colors: [Color(.systemGray6), Color(.systemGray5)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6)], startPoint: .top, endPoint: .bottom)
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(backgroundGradient)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)

            HStack(spacing: 16) {
                ZStack {
                    // Hiệu ứng nền nhỏ cho icon
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 72, height: 72)
                        .blur(radius: 0.5)

                    Image(systemName: viewModel.weatherSymbolName)
                        .font(.system(size: 36))
                        .foregroundStyle(symbolColor)
                        .scaleEffect(animate ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animate)
                }
                .padding(.leading, 12)

                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.cityName)
                        .font(.headline)
                    Text(viewModel.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(viewModel.temperature)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("💧 \(viewModel.humidity)%  🌬️ \(String(format: "%.1f", viewModel.windSpeed)) m/s")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.trailing, 12)
            }
            .padding(.vertical, 12)

            // Hiệu ứng overlay (rain/snow/sun rays)
            Group {
                switch viewModel.weatherMain {
                case "Rain", "Drizzle", "Thunderstorm":
                    RainEffect()
                        .allowsHitTesting(false)
                        .opacity(0.9)
                case "Snow":
                    SnowEffect()
                        .allowsHitTesting(false)
                case "Clear":
                    SunRaysEffect()
                        .allowsHitTesting(false)
                        .opacity(0.6)
                default:
                    EmptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .frame(height: 100)
        .padding(.horizontal)
        .onAppear {
            animate = true
        }
    }

    private var symbolColor: Color {
        switch viewModel.weatherMain {
        case "Clear": return Color.yellow
        case "Clouds": return Color.gray
        case "Rain", "Drizzle", "Thunderstorm": return Color.blue
        case "Snow": return Color.blue.opacity(0.8)
        default: return Color.orange
        }
    }
}

#Preview {
    // Preview with a dummy viewModel
    let vm = WeatherViewModel()
    vm.cityName = "Hanoi"
    vm.temperature = "28°C"
    vm.description = "Trời nắng"
    vm.humidity = 60
    vm.windSpeed = 1.5
    return WeatherCard(viewModel: vm)
}
