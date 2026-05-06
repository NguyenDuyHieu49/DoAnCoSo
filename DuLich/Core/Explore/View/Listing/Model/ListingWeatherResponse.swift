//
//  WeatherResponse.swift
//  DuLich
//
//  Created by Macbook Pro on 5/5/26.
//

import Foundation

struct ListingWeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let name: String

    struct Weather: Codable {
        let description: String
        let icon: String
    }

    struct Main: Codable {
        let temp: Double
        let humidity: Int
    }

    struct Wind: Codable {
        let speed: Double
    }

    struct Clouds: Codable {
        let all: Int
    }
}
