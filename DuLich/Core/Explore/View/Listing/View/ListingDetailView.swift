// FILE: ListingDetailView_Isolated.swift
import SwiftUI
import MapKit
import FirebaseAuth

// Nếu bạn đã có Notification.Name.didCreateBooking ở nơi khác, giữ nguyên; nếu chưa, uncomment
extension Notification.Name {
    static let didCreateBooking = Notification.Name("didCreateBooking")
}

struct ListingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let listing: Listing

    @State private var selectedRoom: String? = nil
    @State private var showMap: MapCameraPosition

    @State private var checkInDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var checkOutDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()

    @State private var isProcessing: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHistory: Bool = false

    @State private var showRoomDetail: Bool = false

    init(listing: Listing){
        self.listing = listing
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.7602, longitude: -80.19),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        self._showMap = State(initialValue: .region(region))
    }

    var body: some View {
        ScrollView {
            ListingImageCarousel(listing: listing)
                .frame(height: 320)
                .overlay(alignment: .topLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .padding(12)
                            .background(Color.white.opacity(0.98))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 56)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title).font(.title).fontWeight(.semibold)
                Text("\(listing.city), \(listing.address)").font(.caption)
            }
            .padding(.leading)

            // ... giữ phần UI khác giống cũ, rút gọn ở đây để ngắn gọn ...
            Spacer(minLength: 400)

            // Bottom bar
            HStack {
                VStack(alignment: .leading) {
                    if let room = selectedRoom, let price = listing.pricePerNight?[room] {
                        Text("\(Int(price)) VNĐ").font(.subheadline).fontWeight(.semibold)
                        Text("Đã chọn: \(room)").font(.footnote).foregroundColor(.pink)
                    } else {
                        Text("Chưa chọn phòng").font(.footnote).foregroundColor(.gray)
                    }
                }
                Spacer()
                NavigationLink(destination: HistoryView(), isActive: $navigateToHistory) { EmptyView() }
                Button {
                    Task { await placeBookingIsolated() }
                } label: {
                    Text(isProcessing ? "Đang xử lý..." : "Thanh toán")
                        .padding()
                        .frame(minWidth: 140)
                        .background(isProcessing ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isProcessing || selectedRoom == nil)
            }
            .padding()
        }
        .sheet(isPresented: $showRoomDetail) {
            if let room = selectedRoom, let price = listing.pricePerNight?[room] {
                RoomDetailView(roomName: room, price: Double(price), listing: listing)
            } else {
                Text("Không có thông tin phòng")
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Thông báo"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: checkInDate) { new in
            if checkOutDate <= new {
                checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: new) ?? new
            }
        }
    }

    // MARK: Actions moved outside body to avoid local-scope modifiers
    @MainActor
    private func placeBookingIsolated() async {
        guard let room = selectedRoom else {
            alertMessage = "Vui lòng chọn phòng trước khi thanh toán."
            showAlert = true
            return
        }
        guard let priceValue = listing.pricePerNight?[room] else {
            alertMessage = "Không lấy được giá phòng."
            showAlert = true
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            let bookingId = try await BookingManager.shared.createBooking(
                hotelId: listing.id,
                hotelName: listing.title,
                hotelAddress: listing.address,
                roomType: room,
                price: Double(priceValue),
                currency: "VND",
                checkIn: checkInDate,
                checkOut: checkOutDate,
                meta: [
                    "userEmail": Auth.auth().currentUser?.email as Any,
                    "userDisplayName": Auth.auth().currentUser?.displayName as Any
                ]
            )

            NotificationCenter.default.post(name: .didCreateBooking, object: nil, userInfo: ["bookingId": bookingId])
            navigateToHistory = true
        } catch {
            alertMessage = "Đặt phòng thất bại: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

// RoomDetailView kept minimal and outside body
struct RoomDetailView: View {
    let roomName: String
    let price: Double
    let listing: Listing

    var body: some View {
        VStack {
            Text(roomName).font(.title2)
            Text("\(Int(price)) VNĐ / đêm")
            Spacer()
        }
        .padding()
    }
}
