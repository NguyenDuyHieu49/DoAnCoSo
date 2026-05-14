//
//  ExploreView.swift
//  DuLich
//
//  Redesigned with Glassmorphism – iOS light theme
//

import SwiftUI
import Combine

struct ExploreView: View {
    @State private var showDestinationSearch = false
    @StateObject var viewModel = ExploreViewModel(service: ExploreService())
    @StateObject var weatherVM = WeatherViewModel()
    @State private var showWeatherDetail = false

    var body: some View {
        NavigationStack {
            if showDestinationSearch {
                DestinationSearch(show: $showDestinationSearch) { query in
                    viewModel.searchDestination(query)
                }
            } else {
                ZStack(alignment: .top) {
                    // Nền gradient toàn màn hình
                    LinearGradient(
                        colors: [
                            Color(red: 0.52, green: 0.76, blue: 0.96),
                            Color(red: 0.78, green: 0.91, blue: 1.00),
                            Color(red: 0.93, green: 0.96, blue: 1.00)
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {

                            // Search bar
                            GlassSearchBar()
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        showDestinationSearch.toggle()
                                    }
                                }

                            // Weather card
                            WeatherCard(viewModel: weatherVM)
                                .onAppear {
                                    Task { await weatherVM.fetchWeather(for: "Hanoi") }
                                }
                                .onTapGesture {
                                    showWeatherDetail = true
                                }
                                .sheet(isPresented: $showWeatherDetail) {
                                    WeatherDetailView(viewModel: weatherVM)
                                }

                            // Section header
                            HStack {
                                Text("Gợi ý cho bạn")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(white: 0.12))
                                Spacer()
                                Text("\(viewModel.listings.count) địa điểm")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(white: 0.45))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 4)

                            // Listings
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.listings) { listing in
                                    NavigationLink(value: listing) {
                                        ListingItemView(listing: listing)
                                            .frame(height: 400)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            // Glass card shadow
                                            .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .strokeBorder(Color.white.opacity(0.45), lineWidth: 0.8)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                        .padding(.top, 12)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Khám phá")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(white: 0.10))
                    }
                }
                .navigationDestination(for: Listing.self) { listing in
                    ListingDetailView(listing: listing)
                        .navigationBarBackButtonHidden()
                }
            }
        }
    }
}

// MARK: – Glass Search Bar
// Thay thế SearchBar() gốc với phong cách glassmorphism
private struct GlassSearchBar: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(white: 0.40))

            Text("Tìm kiếm điểm đến…")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(white: 0.50))

            Spacer()

            // Filter pill
            HStack(spacing: 4) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .medium))
                Text("Lọc")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.90))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color(red: 0.15, green: 0.45, blue: 0.90).opacity(0.12))
                    .overlay(
                        Capsule().strokeBorder(
                            Color(red: 0.15, green: 0.45, blue: 0.90).opacity(0.30),
                            lineWidth: 0.7
                        )
                    )
            )
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.35))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.80), Color.white.opacity(0.30)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.55), radius: 2, x: 0, y: -1)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    ExploreView()
}
