// ExploreView.swift
// Thêm nút "+" cho Admin để mở AddHotelView

import SwiftUI
import Combine

struct ExploreView: View {
    @State private var showDestinationSearch = false
    @StateObject var viewModel = ExploreViewModel(service: ExploreService())
    @StateObject var weatherVM = WeatherViewModel()
    @State private var showWeatherDetail = false
    @State private var showAddHotel = false         // ← Admin: show AddHotelView

    @EnvironmentObject private var authState: AuthState

    var body: some View {
        NavigationStack {
            if showDestinationSearch {
                DestinationSearch(show: $showDestinationSearch) { query in
                    viewModel.searchDestination(query)
                }
            } else {
                ZStack(alignment: .bottomTrailing) {

                    // ── Main background ──────────────────────────────────
                    ZStack(alignment: .top) {
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
                                    .onTapGesture { showWeatherDetail = true }
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
                                                .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 0.8)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, authState.isAdmin ? 90 : 32)  
                            }
                            .padding(.top, 12)
                        }
                    }

                    // ── Admin FAB: nút thêm khách sạn ────────────────────
                    if authState.isAdmin {
                        adminAddButton
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Khám phá")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(white: 0.10))
                    }
                    // Admin badge ở navigation bar
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
                        // Reload listings sau khi thêm thành công
                        Task { await viewModel.loadListings() }
                    }
                }
            }
        }
    }

    // MARK: - Admin FAB
    private var adminAddButton: some View {
        Button {
            showAddHotel = true
        } label: {
            ZStack {
                // Shadow circle
                Circle()
                    .fill(Color(red: 0.15, green: 0.40, blue: 0.90).opacity(0.30))
                    .frame(width: 64, height: 64)
                    .blur(radius: 10)
                    .offset(y: 4)

                // Main button
                Circle()
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.48, blue: 0.98),
                            Color(red: 0.35, green: 0.62, blue: 1.00)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 58, height: 58)
                    .overlay(
                        Circle().strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
                    )

                // Glass sheen
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.30), Color.clear],
                        startPoint: .top, endPoint: .center
                    ))
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

    // MARK: - Admin Badge (toolbar)
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
                .overlay(Capsule().strokeBorder(Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.5), lineWidth: 1))
        )
    }
}

// MARK: – Glass Search Bar (giữ nguyên)
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
                .overlay(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.35)))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.80), Color.white.opacity(0.30)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
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
        .environmentObject(AuthState())
}
