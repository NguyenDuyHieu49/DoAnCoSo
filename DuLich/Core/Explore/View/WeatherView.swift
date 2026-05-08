//
//  WeatherView.swift
//  DuLich
//
//  Created by Macbook Pro on 1/5/26.
//

import SwiftUI

struct MiniWeatherCard: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.temperature)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(viewModel.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 150, height: 100)
        .background(Color.blue.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
        }
    }
}

