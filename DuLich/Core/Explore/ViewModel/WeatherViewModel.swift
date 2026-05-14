//
//  WeatherViewModel.swift
//  BookingApp
//
//  Created by Macbook Pro on 6/5/26.
//


import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var temperature: String = "--"
    @Published var description: String = "Đang tải..."
    @Published var humidity: Int = 0
    @Published var windSpeed: Double = 0
    @Published var clouds: Int = 0
    @Published var cityName: String = "Hanoi"
    
    // Trường để lưu loại thời tiết chính (ví dụ: Clear, Clouds, Rain...)
    @Published var weatherMain: String = "Unknown"
    
    func fetchWeather(for city: String) async {
        let apiKey = "8ff885aa6cce5897224ccf0665e7199d" // tốt hơn: load từ config
        let cityEscaped = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityEscaped),VN&appid=\(apiKey)&units=metric&lang=vi"
        
        guard let url = URL(string: urlString) else {
            self.description = "URL không hợp lệ"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("Weather API raw:", String(data: data, encoding: .utf8) ?? "<no data>")
            let result = try JSONDecoder().decode(ListingWeatherResponse.self, from: data)
            
            self.cityName = result.name
            self.temperature = "\(Int(result.main.temp))°C"
            self.description = result.weather.first?.description.capitalized ?? "Không rõ"
            self.humidity = result.main.humidity
            self.windSpeed = result.wind.speed
            self.clouds = result.clouds.all
            // Map từ mô tả (vi) sang nhóm chính để dùng icon/màu
            let viDesc = result.weather.first?.description.lowercased() ?? ""
            if viDesc.contains("mưa giông") || viDesc.contains("dông") || viDesc.contains("sấm") || viDesc.contains("sét") {
                self.weatherMain = "Thunderstorm"
            } else if viDesc.contains("mưa phùn") || viDesc.contains("phùn") {
                self.weatherMain = "Drizzle"
            } else if viDesc.contains("mưa") {
                self.weatherMain = "Rain"
            } else if viDesc.contains("tuyết") {
                self.weatherMain = "Snow"
            } else if viDesc.contains("sương mù") || viDesc.contains("sương") || viDesc.contains("khói mù") || viDesc.contains("mù") || viDesc.contains("mờ sương") || viDesc.contains("haze") {
                self.weatherMain = "Mist"
            } else if viDesc.contains("bão cát") || viDesc.contains("bụi") || viDesc.contains("cát") || viDesc.contains("tro") {
                self.weatherMain = "Dust"
            } else if viDesc.contains("lốc") || viDesc.contains("lốc xoáy") {
                self.weatherMain = "Tornado"
            } else if viDesc.contains("gió giật") || viDesc.contains("gió mạnh") {
                self.weatherMain = "Squall"
            } else if viDesc.contains("mây") || viDesc.contains("u ám") || viDesc.contains("nhiều mây") {
                self.weatherMain = "Clouds"
            } else if viDesc.contains("nắng") || viDesc.contains("trong lành") || viDesc.contains("quang đãng") || viDesc.contains("ít mây") {
                self.weatherMain = "Clear"
            } else {
                self.weatherMain = "Unknown"
            }
        } catch {
            print("Weather fetch error:", error)
            self.description = "Lỗi tải dữ liệu"
            self.weatherMain = "Unknown"
        }
    }
}

extension WeatherViewModel {
    var weatherSymbolName: String {
        switch weatherMain {
        case "Clear": return "sun.max.fill"
        case "Clouds": return "cloud.fill"
        case "Rain": return "cloud.rain.fill"
        case "Drizzle": return "cloud.drizzle.fill"
        case "Thunderstorm": return "cloud.bolt.rain.fill"
        case "Snow": return "snow"
        case "Mist", "Fog", "Haze": return "cloud.fog.fill"
        case "Smoke": return "smoke.fill"
        case "Dust", "Sand", "Ash": return "sun.dust.fill"
        case "Squall": return "wind"
        case "Tornado": return "tornado"
        default: return "cloud.sun.fill"
        }
    }
    
    var symbolColor: String {
        switch weatherMain {
        case "Clear": return "yellow"
        case "Clouds": return "gray"
        case "Rain", "Drizzle", "Thunderstorm": return "blue"
        case "Snow": return "cyan"
        case "Mist", "Fog", "Haze": return "gray"
        default: return "orange"
        }
            
    }
}
