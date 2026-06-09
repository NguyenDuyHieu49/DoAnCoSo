//
//  RoomDetailView.swift
//  Hotelia
//
//  Created by Macbook Pro on 20/5/26.
//

import SwiftUI
import FirebaseFirestore

struct RoomInfo: Identifiable {
    let id: String
    let roomNumber: String
    var isBooked: Bool
}

struct RoomDetailView: View {
    let roomName: String
    let price: Double
    let listing: Listing
    let checkInDate: Date
    let checkOutDate: Date
    var onConfirm: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var rooms: [RoomInfo] = []
    @State private var selectedRoomNumber: String? = nil
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.96, blue: 1.00).ignoresSafeArea()
            Circle()
                .fill(Color(red: 0.55, green: 0.75, blue: 1.00).opacity(0.30))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 80, y: -50)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 36, height: 4)
                        .padding(.top, 10)

                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Glass.accentLight)
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                    .stroke(Glass.cardStroke2, lineWidth: 0.8))
                                .frame(width: 60, height: 60)
                            Image(systemName: "bed.double.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Glass.accent)
                        }
                        Text(roomName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Glass.textPrimary)
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(Int(price))")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(Glass.accent)
                            Text("room_per_night")
                                .font(.system(size: 13))
                                .foregroundStyle(Glass.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "text.alignleft").foregroundStyle(Glass.accent)
                            Text("room_description_title")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Glass.textPrimary)
                        }
                        Text("room_description_body")
                            .font(.system(size: 14))
                            .foregroundStyle(Glass.textSecondary)
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .glassCard()
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "list.number").foregroundStyle(Glass.accent)
                            Text("select_room_number")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Glass.textPrimary)
                        }

                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if rooms.isEmpty {
                            Text("no_rooms_available")
                                .font(.system(size: 14))
                                .foregroundStyle(Glass.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 10
                            ) {
                                ForEach(rooms) { room in
                                    roomCell(room: room)
                                }
                            }
                        }
                    }
                    .padding(18)
                    .glassCard()
                    .padding(.horizontal, 16)

                    Button {
                        if let roomNumber = selectedRoomNumber {
                            onConfirm(roomNumber)
                            dismiss()
                        }
                    } label: {
                        Text("confirm")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: Glass.cornerMd)
                                    .fill(selectedRoomNumber == nil
                                          ? Glass.accent.opacity(0.35)
                                          : Glass.accent)
                                    .shadow(color: Glass.accent.opacity(0.30), radius: 10, x: 0, y: 5)
                            )
                    }
                    .disabled(selectedRoomNumber == nil)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 32)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .task { await loadRooms() }
    }

    private func roomCell(room: RoomInfo) -> some View {
        let isSelected = selectedRoomNumber == room.roomNumber
        return Button {
            if !room.isBooked {
                withAnimation(.spring(response: 0.3)) {
                    selectedRoomNumber = room.roomNumber
                }
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: room.isBooked ? "lock.fill" : "bed.double")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        room.isBooked ? Glass.textTertiary :
                        isSelected ? Glass.accent : Glass.textSecondary
                    )
                Text(room.roomNumber)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        room.isBooked ? Glass.textTertiary :
                        isSelected ? Glass.accent : Glass.textPrimary
                    )
                if room.isBooked {
                    Text("room_booked")
                        .font(.system(size: 9))
                        .foregroundStyle(Glass.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        room.isBooked ? Color.gray.opacity(0.08) :
                        isSelected ? Glass.accentLight : Color.white.opacity(0.55)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                room.isBooked ? Color.gray.opacity(0.2) :
                                isSelected ? Glass.accent : Glass.cardStroke2,
                                lineWidth: isSelected ? 1.5 : 0.8
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(room.isBooked)
    }

    private func loadRooms() async {
        isLoading = true
        do {
            let snapshot = try await Firestore.firestore()
                .collection("rooms")
                .whereField("hotelId", isEqualTo: listing.id)
                .whereField("roomType", isEqualTo: roomName)
                .getDocuments()

            var result: [RoomInfo] = []
            for doc in snapshot.documents {
                let data = doc.data()
                let roomNumber = data["roomNumber"] as? String ?? ""
                let isBooked = await checkIfBooked(roomNumber: roomNumber)
                result.append(RoomInfo(id: doc.documentID, roomNumber: roomNumber, isBooked: isBooked))
            }
            rooms = result.sorted { $0.roomNumber < $1.roomNumber }
        } catch {
            print("[RoomDetailView] loadRooms error:", error.localizedDescription)
        }
        isLoading = false
    }

    private func checkIfBooked(roomNumber: String) async -> Bool {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("bookings")
                .whereField("hotelId", isEqualTo: listing.id)
                .whereField("roomNumber", isEqualTo: roomNumber)
                .getDocuments()

            for doc in snapshot.documents {
                let data = doc.data()
                let checkOut = (data["checkOut"] as? Timestamp)?.dateValue() ?? Date.distantPast
                let status = data["status"] as? String ?? "active"
                if checkOut > Date() && status != "cancelled" {
                    return true
                }
            }
        } catch {
            print("[checkIfBooked] error:", error.localizedDescription)
        }
        return false
    }
}
