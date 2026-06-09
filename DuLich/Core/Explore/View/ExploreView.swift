// ExploreView.swift

import SwiftUI
import Combine

struct ExploreView: View {

    @State private var showDestinationSearch = false
    @StateObject var viewModel = ExploreViewModel(service: ExploreService())

    @State private var showWeatherDetail = false
    @State private var showAddHotel = false
    @State private var selectedWeatherIndex = 0

    @StateObject var weatherHN = WeatherViewModel()
    @StateObject var weatherHCM = WeatherViewModel()
    @StateObject var weatherHP = WeatherViewModel()
    @StateObject var weatherCT = WeatherViewModel()

    @EnvironmentObject private var authState: AuthState

    var body: some View {

        NavigationStack {

            if showDestinationSearch {

                DestinationSearch(
                    show: $showDestinationSearch,
                    listings: viewModel.listings
                ) { query in
                    viewModel.searchDestination(query)
                }

            } else {

                ZStack(alignment: .bottomTrailing) {

                    backgroundGradient

                    ScrollView(showsIndicators: false) {

                        VStack(spacing: 16) {

                            GlassSearchBar()
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        showDestinationSearch.toggle()
                                    }
                                }

                            weatherSection

                            listingsHeader

                            listingsSection
                        }
                        .padding(.top, 12)
                    }

                    if authState.isAdmin {
                        adminAddButton
                    }
                }
                .navigationBarTitleDisplayMode(.inline)

                .toolbar {

                    ToolbarItem(placement: .principal) {
                        Text("explore_title")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(white: 0.10))
                    }

                    if authState.isAdmin {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            adminBadge
                        }
                    }
                }

                .navigationDestination(for: Listing.self) { listing in
                    ListingDetailView(listing: listing)
                        .navigationBarBackButtonHidden()
                }

                .sheet(isPresented: $showAddHotel) {
                    AddHotelView {
                        Task { await viewModel.loadListings() }
                    }
                }
            }
        }
    }
}

extension ExploreView {
    
    private var backgroundGradient: some View {
        
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
    }
    
    private var weatherSection: some View {
        
        TabView(selection: $selectedWeatherIndex) {
            
            WeatherCard(viewModel: weatherHN).tag(0)
            WeatherCard(viewModel: weatherHCM).tag(1)
            WeatherCard(viewModel: weatherHP).tag(2)
            WeatherCard(viewModel: weatherCT).tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 130)
        
        .task {
            async let t1: () = weatherHN.fetchWeather(for: "Hanoi")
            async let t2: () = weatherHCM.fetchWeather(for: "Ho Chi Minh City")
            async let t3: () = weatherHP.fetchWeather(for: "Haiphong")
            async let t4: () = weatherCT.fetchWeather(for: "Can Tho")
            
            _ = await (t1, t2, t3, t4)
        }
        
        .onTapGesture {
            showWeatherDetail = true
        }
        
        .sheet(isPresented: $showWeatherDetail) {
            
            switch selectedWeatherIndex {
                
            case 0:
                WeatherDetailView(viewModel: weatherHN)
                
            case 1:
                WeatherDetailView(viewModel: weatherHCM)
                
            case 2:
                WeatherDetailView(viewModel: weatherHP)
                
            case 3:
                WeatherDetailView(viewModel: weatherCT)
                
            default:
                WeatherDetailView(viewModel: weatherHN)
            }
        }
    }
    
    private var listingsHeader: some View {
        
        HStack {
            
            Text("suggestions_for_you")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Color(white: 0.12))
                .frame(alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
    
    private var listingsSection: some View {
        Group {
            if viewModel.listings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(Color(white: 0.6))
                    
                    Text(String(localized: "there_no_destination"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button {
                        viewModel.searchDestination("")
                    } label: {
                        Text(String(localized: "view_all"))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.90))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.15, green: 0.45, blue: 0.90).opacity(0.10))
                                    .overlay(Capsule()
                                        .strokeBorder(Color(red: 0.15, green: 0.45, blue: 0.90).opacity(0.30), lineWidth: 1))
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
                .padding(.bottom, 32)
                
            } else {
                VStack(alignment: .leading) {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(viewModel.listings) { listing in
                                NavigationLink(value: listing) {
                                    ListingItemView(listing: listing)
                                        .frame(width: 280, height: 340)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(Color.white.opacity(0.45), lineWidth: 0.8)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                    }
                    
                    ForEach(viewModel.groupedListings, id: \.city) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95))
                                Text(String(localized: "hotel_in \(group.city)"))
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(white: 0.12))
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(group.listings) { listing in
                                        NavigationLink(value: listing) {
                                            ListingItemView(listing: listing)
                                                .frame(width: 280, height: 340)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 0.8)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.bottom, authState.isAdmin ? 90 : 32)
                }
            }
        }
    }
}
extension ExploreView {

    private var adminAddButton: some View {

        Button {

            showAddHotel = true

        } label: {

            ZStack {

                Circle()
                    .fill(Color(red: 0.15, green: 0.40, blue: 0.90).opacity(0.30))
                    .frame(width: 64, height: 64)
                    .blur(radius: 10)
                    .offset(y: 4)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.20, green: 0.48, blue: 0.98),
                                Color(red: 0.35, green: 0.62, blue: 1.00)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)

                    .overlay(
                        Circle()
                            .strokeBorder(
                                Color.white.opacity(0.45),
                                lineWidth: 1.2
                            )
                    )

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.30), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(width: 58, height: 58)

                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
        .transition(.scale.combined(with: .opacity))
    }

    private var adminBadge: some View {

        HStack(spacing: 4) {

            Image(systemName: "shield.checkered")
                .font(.system(size: 11, weight: .semibold))

            Text("Admin")
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .foregroundColor(Color(red: 0.9, green: 0.65, blue: 0.1))
        .padding(.horizontal, 9)
        .padding(.vertical, 4)

        .background(
            Capsule()
                .fill(Color(red: 1.0, green: 0.85, blue: 0.25).opacity(0.18))

                .overlay(
                    Capsule()
                        .strokeBorder(
                            Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.5),
                            lineWidth: 1
                        )
                )
        )
    }
}

private struct GlassSearchBar: View {

    var body: some View {

        HStack(spacing: 10) {

            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(white: 0.40))

            Text("search_destination")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(white: 0.50))

            Spacer()

            HStack(spacing: 4) {

                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .medium))

                Text("filter")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.90))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)

            .background(
                Capsule()
                    .fill(Color(red: 0.15, green: 0.45, blue: 0.90).opacity(0.12))

                    .overlay(
                        Capsule()
                            .strokeBorder(
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
                                colors: [
                                    Color.white.opacity(0.80),
                                    Color.white.opacity(0.30)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )

                .shadow(
                    color: Color.black.opacity(0.07),
                    radius: 8,
                    x: 0,
                    y: 4
                )

                .shadow(
                    color: Color.white.opacity(0.55),
                    radius: 2,
                    x: 0,
                    y: -1
                )
        )
        .padding(.horizontal, 16)
    }
}

#Preview {

    ExploreView()
        .environmentObject(AuthState())
}
