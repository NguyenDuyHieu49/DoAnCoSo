// ListingDetailView.swift
import SwiftUI
import MapKit
import FirebaseAuth

extension Notification.Name {
    static let didCreateBooking = Notification.Name("didCreateBooking")
}

struct ListingDetailView: View {
    @Environment(\.dismiss) var dismiss
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
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white.opacity(0.98))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .padding(.leading, 16)
                    .padding(.top, 56)
                    .zIndex(2)
                    .accessibilityIdentifier("backButtonVariantA")
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title)
                    .font(.title)
                    .fontWeight(.semibold)

                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                        Text("\(listing.rating)")
                        Text(" - ")
                        Text("28 reviews")
                            .underline()
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.yellow)
                    .font(.caption)

                    Text("\(listing.city), \(listing.address)")
                }
                .font(.caption)
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Khách sạn thuộc sở hữu bởi \(listing.ownerName)")
                        .font(.headline)
                        .frame(width: 250, alignment: .leading)
                }
                .frame(width: 300, alignment: .leading)
                Spacer()
                Image(listing.ownerImangUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                ForEach(listing.features) { feature in
                    HStack(spacing: 12){
                        Image(systemName: feature.imageName)

                        VStack(alignment: .leading){
                            Text(feature.title)
                                .font(.footnote)
                                .fontWeight(.semibold)

                            Text(feature.subtitle)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                }
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                Text("Hãy chọn loại phòng bạn muốn")
                    .font(.headline)

                if let roomPrices = listing.pricePerNight {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(roomPrices.keys.sorted(), id: \.self) { room in
                                let price = roomPrices[room] ?? 0
                                VStack(spacing: 8) {
                                    Image(systemName: "bed.double")
                                        .font(.title2)
                                    Text(room)
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                    Text("\(Int(price)) VNĐ")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 132, height: 110)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedRoom == room ? Color.pink : Color.gray, lineWidth: 2)
                                }
                                .onTapGesture {
                                    selectedRoom = room
                                    showRoomDetail = true
                                }
                                .onLongPressGesture {
                                    selectedRoom = room
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollTargetBehavior(.paging)
                    .sheet(isPresented: $showRoomDetail) {
                        if let room = selectedRoom, let price = listing.pricePerNight?[room] {
                            RoomDetailView(roomName: room, price: Double(price), listing: listing)
                        } else {
                            VStack {
                                Text("Không tìm thấy thông tin phòng")
                                    .padding()
                                Button("Đóng") { showRoomDetail = false }
                            }
                            .padding()
                        }
                    }
                }
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Chọn ngày")
                    .font(.headline)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Check in")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        DatePicker("", selection: $checkInDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Check out")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        DatePicker("", selection: $checkOutDate, in: Calendar.current.date(byAdding: .day, value: 1, to: checkInDate)!..., displayedComponents: .date)
                            .labelsHidden()
                    }
                }
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                Text("Các tiện ích được cung cấp")
                    .font(.headline)

                ForEach(listing.amenities, id: \.self) { amenity in
                    HStack {
                        Image(systemName: amenity.ImageName)
                        Text(amenity.title)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                Text("Địa điểm")
                    .font(.headline)

                Map()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea()
        .padding(.bottom, 64)
        .overlay(alignment: .bottom) {
            VStack {
                Divider()
                    .padding(.bottom)

                HStack {
                    VStack(alignment: .leading) {
                        if let selectedRoom = selectedRoom,
                           let price = listing.pricePerNight?[selectedRoom] {
                            Text("\(Int(price)) VNĐ")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Giá một đêm")
                                .font(.footnote)
                            Text("Đã chọn: \(selectedRoom)")
                                .font(.footnote)
                                .foregroundStyle(.pink)
                        } else {
                            Text("Chưa chọn phòng")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                    }
                    Spacer()

                    NavigationLink(destination: HistoryView(), isActive: $navigateToHistory) {
                        EmptyView()
                    }

                    Button(action: {
                        Task {
                            await placeBooking()
                        }
                    }) {
                        Text(isProcessing ? "Đang xử lý..." : "Thanh toán")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isProcessing ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isProcessing || selectedRoom == nil)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showRoomDetail) {
            if let room = selectedRoom, let price = listing.pricePerNight?[room] {
                RoomDetailView(roomName: room, price: Double(price), listing: listing)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Thông báo"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: checkInDate) { new in
            if checkOutDate <= new {
                checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: new) ?? new
            }
        }
    }

    // MARK: - Actions

    @MainActor
    private func placeBooking() async {
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
            let hotelId = listing.id
            let hotelName = listing.title
            let hotelAddress = listing.address
            let roomType = room
            let currency = "VND"
            let checkIn = checkInDate
            let checkOut = checkOutDate

            var meta: [String: Any] = [:]
            if let user = Auth.auth().currentUser {
                meta["userEmail"] = user.email as Any
                meta["userDisplayName"] = user.displayName as Any
            }

            // Create booking on server (BookingManager should return the created document id)
            let bookingId = try await BookingManager.shared.createBooking(
                hotelId: hotelId,
                hotelName: hotelName,
                hotelAddress: hotelAddress,
                roomType: roomType,
                price: Double(priceValue),
                currency: currency,
                checkIn: checkIn,
                checkOut: checkOut,
                meta: meta
            )

            // Post notification so HistoryViewModel can insert the new booking immediately
            NotificationCenter.default.post(name: .didCreateBooking, object: nil, userInfo: ["bookingId": bookingId])

            // Navigate to history screen
            navigateToHistory = true

        } catch {
            alertMessage = "Đặt phòng thất bại: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

struct RoomDetailView: View {
    let roomName: String
    let price: Double
    let listing: Listing

    var body: some View {
        VStack(spacing: 16) {
            Text(roomName)
                .font(.title2)
                .fontWeight(.semibold)
            Text("\(Int(price)) VNĐ / đêm")
                .font(.headline)
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Text("Mô tả phòng")
                    .font(.headline)
                Text("Phòng gồm có \(listing.amenities), \(listing.features)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
            Spacer()
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

// Preview
#Preview {
    ListingDetailView(listing: DeveloperPreview.shared.listings[0])
}
