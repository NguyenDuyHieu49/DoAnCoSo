// ListingDetailView.swift
import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore
extension Notification.Name {
    static let didCreateBooking = Notification.Name("didCreateBooking")
}

struct ListingDetailView: View {
    @Environment(\.dismiss) var dismiss
    let listing: Listing
    
    init(listing: Listing) {
        self.listing = listing
        if listing.latitude != 0 && listing.longitude != 0 {
            let coord = CLLocationCoordinate2D(latitude: listing.latitude, longitude: listing.longitude)
            let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 21.0000, longitudeDelta: 105.8500))
            self._showMap = State(initialValue: .region(region))
        } else {
            self._showMap = State(initialValue: .automatic)
        }
    }

    
    private static let sampleReviews: [Review] = [
        Review(id: "sample1", authorId: nil, authorName: "Ronaldo và Messi", rating: 4.5, comment: "Phòng sạch, nhân viên thân thiện. View đẹp buổi sáng.", createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, likes: 3, isLikedByCurrentUser: false),
        Review(id: "sample2", authorId: nil, authorName: "Sơn Tùng MTP", rating: 5.0, comment: "Dịch vụ tuyệt vời, bữa sáng ngon. Sẽ quay lại.", createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, likes: 5, isLikedByCurrentUser: false),
        Review(id: "sample3", authorId: nil, authorName: "Donald Trump", rating: 4.0, comment: "Phòng rộng, hơi ồn vào ban đêm nhưng tổng thể ổn.", createdAt: Calendar.current.date(byAdding: .day, value: -12, to: Date())!, likes: 1, isLikedByCurrentUser: false)
    ]
    @State private var selectedRoom: String? = nil
    @State private var showMap: MapCameraPosition = .automatic
    @State private var checkInDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var checkOutDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
    @State private var isProcessing: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHistory: Bool = false
    @State private var showRoomDetail: Bool = false
    @State private var reviews: [Review] = []
    
    @State private var isComposingReview: Bool = false
    @State private var currentReviewIndex: Int = 0
    private func formatRating(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
    
    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        df.locale = Locale(identifier: "vi_VN")
        return df.string(from: date)
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
                // Title
                Text(listing.title)
                    .font(.title)
                    .fontWeight(.semibold)
                
                    HStack(alignment: .center, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", listing.rating))
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text("·")
                                .foregroundColor(.secondary)
                            Text(reviews.isEmpty ? "Chưa có đánh giá" : "\(reviews.count) đánh giá")
                                .font(.caption)
                                .underline()
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        Button(action: {
                            withAnimation { currentReviewIndex = 0 }
                        }) {
                            Text("Xem đánh giá")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .font(.caption)

                    // Location
                    Text("\(listing.city), \(listing.address)")
                        .font(.caption)
                        .foregroundColor(.secondary)

            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            let displayReviews = reviews.isEmpty ? Self.sampleReviews : reviews

            TabView(selection: $currentReviewIndex) {
                ForEach(Array(displayReviews.enumerated()), id: \.element.id) { index, review in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(review.authorName.prefix(1)))
                                        .font(.headline)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(review.authorName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text(String(format: "%.1f", review.rating))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Text(review.comment)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        HStack {
                            Text(review.createdAt, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                toggleLikeLocal(reviewId: review.id)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: review.isLikedByCurrentUser ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    Text("\(review.likes)")
                                }
                                .font(.caption2)
                                .padding(6)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 12)
                    .tag(index)
                }
            }
            .frame(height: 200)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 6)

            // Composer button
            HStack {
                Spacer()
                Button {
                    isComposingReview = true
                } label: {
                    Text("Đánh giá & Viết nhận xét")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding(.top, 8)
            
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
                
                Map(position: $showMap)
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
        .sheet(isPresented: $isComposingReview) {
            ReviewComposerView { authorName, rating, comment in
                submitReviewLocal(authorName: authorName, rating: rating, comment: comment)
            }
        }
        .onAppear {
            if reviews.isEmpty {
                reviews = Self.sampleReviews
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: checkInDate) { new in
            if checkOutDate <= new {
                checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: new) ?? new
            }
        }
    }
    private func toggleLikeLocal(reviewId: String) {
        // Cập nhật mảng reviews nếu review là review thật (trong reviews)
        if let idx = reviews.firstIndex(where: { $0.id == reviewId }) {
            if reviews[idx].isLikedByCurrentUser {
                reviews[idx].isLikedByCurrentUser = false
                reviews[idx].likes = max(0, reviews[idx].likes - 1)
            } else {
                reviews[idx].isLikedByCurrentUser = true
                reviews[idx].likes += 1
            }
            return
        }

        // Nếu đang hiển thị sample (vì reviews rỗng) và muốn cho phép like sample,
        // cập nhật mảng reviews bằng cách chuyển sample thành mảng có thể sửa.
        // (Ở đây ta chuyển sample tạm thời sang reviews để cập nhật UI)
        var samples = Self.sampleReviews
        if let sIdx = samples.firstIndex(where: { $0.id == reviewId }) {
            if samples[sIdx].isLikedByCurrentUser {
                samples[sIdx].isLikedByCurrentUser = false
                samples[sIdx].likes = max(0, samples[sIdx].likes - 1)
            } else {
                samples[sIdx].isLikedByCurrentUser = true
                samples[sIdx].likes += 1
            }
            // Gán samples vào reviews để UI phản ánh thay đổi
            reviews = samples
        }
    }

    private func placeBooking() async {
        // Prevent multiple taps
        if isProcessing { return }
        await MainActor.run { isProcessing = true }

        // Basic validation
        guard let selectedRoom = selectedRoom, let price = listing.pricePerNight?[selectedRoom] else {
            await MainActor.run {
                alertMessage = "Vui lòng chọn loại phòng trước khi thanh toán."
                showAlert = true
                isProcessing = false
            }
            return
        }
        guard checkOutDate > checkInDate else {
            await MainActor.run {
                alertMessage = "Ngày trả phòng phải sau ngày nhận phòng."
                showAlert = true
                isProcessing = false
            }
            return
        }

        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1s delay to mimic network

            await MainActor.run {
                NotificationCenter.default.post(name: .didCreateBooking, object: nil, userInfo: [
                    "listingId": listing.id,
                    "room": selectedRoom,
                    "price": price,
                    "checkIn": checkInDate,
                    "checkOut": checkOutDate
                ])

                isProcessing = false
                navigateToHistory = true
            }
        } catch {
            await MainActor.run {
                alertMessage = "Đã có lỗi xảy ra khi đặt phòng. Vui lòng thử lại."
                showAlert = true
                isProcessing = false
            }
        }
    }
    
    @MainActor
    private func submitReviewLocal(authorName: String, rating: Double, comment: String) {
        let createdReview = Review(
            id: UUID().uuidString,
            authorId: nil,
            authorName: authorName.isEmpty ? "Khách" : authorName,
            rating: rating,
            comment: comment,
            createdAt: Date(),
            likes: 0,
            isLikedByCurrentUser: false
        )
        reviews.insert(createdReview, at: 0)
        currentReviewIndex = 0
        isComposingReview = false
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
                    Text("Phòng khách sạn được thiết kế theo phong cách hiện đại và sang trọng, mang lại cảm giác ấm cúng nhưng vẫn đầy đủ tiện nghi. Không gian phòng rộng rãi với giường lớn êm ái, chăn ga sạch sẽ và ánh đèn vàng dịu nhẹ tạo cảm giác thư giãn cho khách lưu trú. Cửa sổ lớn giúp đón ánh sáng tự nhiên và mở ra khung cảnh đẹp của thành phố. Trong phòng được trang bị đầy đủ các tiện ích như điều hòa, tivi màn hình phẳng, wifi tốc độ cao, minibar và bàn làm việc. Phòng tắm riêng hiện đại với vòi sen nước nóng, khăn tắm mềm mại và các vật dụng cá nhân cần thiết. Đây là lựa chọn lý tưởng cho cả khách du lịch và khách đi công tác muốn tận hưởng sự thoải mái và tiện nghi trong suốt thời gian lưu trú")
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
    
}
