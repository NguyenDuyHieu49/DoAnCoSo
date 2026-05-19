//
//  AdminDashboardView.swift
//  Hotelia
//
//  Created by Macbook Pro on 19/5/26.
//

import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject private var authState: AuthState
    @State private var showAddHotel = false
    @State private var hotels: [HotelForm] = []
    @State private var isLoading = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.52, green: 0.76, blue: 0.96),
                    Color(red: 0.85, green: 0.93, blue: 1.00),
                    Color(red: 0.93, green: 0.96, blue: 1.00)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Header card
                    HStack(spacing: 14) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Xin chào, Admin")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(white: 0.1))
                            Text("\(hotels.count) khách sạn trong hệ thống")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(Color(white: 0.45))
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.30)))
                            .overlay(RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.white.opacity(0.6), lineWidth: 0.8))
                    )
                    .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 4)

                    // Nút thêm khách sạn
                    Button {
                        showAddHotel = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Thêm khách sạn mới")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.15, green: 0.40, blue: 0.90),
                                             Color(red: 0.30, green: 0.58, blue: 1.0)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .shadow(color: Color(red: 0.2, green: 0.45, blue: 0.9).opacity(0.4),
                                        radius: 12, x: 0, y: 6)
                        )
                    }

                    // Danh sách khách sạn
                    if isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if hotels.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "building.slash")
                                .font(.system(size: 44))
                                .foregroundColor(Color(white: 0.6))
                            Text("Chưa có khách sạn nào")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(Color(white: 0.5))
                        }
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(hotels) { hotel in
                                hotelRow(hotel)
                            }
                        }
                    }

                    Spacer(minLength: 32)
                }
                .padding(16)
            }
        }
        .navigationTitle("Quản trị")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showAddHotel) {
            AddHotelView {
                Task { await loadHotels() }
            }
        }
        .task {
            await loadHotels()
        }
    }

    // MARK: - Hotel row
    private func hotelRow(_ hotel: HotelForm) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.10))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(hotel.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(white: 0.1))
                Text(hotel.city.isEmpty ? "Chưa có địa chỉ" : hotel.city)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Color(white: 0.5))
            }

            Spacer()

            // Xoá
            Button {
                Task {
                    try? await AdminHotelManager.shared.deleteHotel(id: hotel.id)
                    await loadHotels()
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 0.9, green: 0.25, blue: 0.25))
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.9, green: 0.25, blue: 0.25).opacity(0.10))
                    )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.30)))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.8))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    // MARK: - Load
    private func loadHotels() async {
        isLoading = true
        hotels = (try? await AdminHotelManager.shared.fetchHotels()) ?? []
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        AdminDashboardView()
            .environmentObject(AuthState())
    }
}
