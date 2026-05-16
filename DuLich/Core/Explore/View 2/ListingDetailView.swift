// ListingDetailView.swift
import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore

extension Notification.Name {
    static let didCreateBooking = Notification.Name("didCreateBooking")
}

private enum Glass {
    static let pageBg        = Color(red: 0.92, green: 0.95, blue: 1.00)
    static let blobBlue      = Color(red: 0.55, green: 0.75, blue: 1.00)
    static let blobPurple    = Color(red: 0.75, green: 0.65, blue: 1.00)

    static let cardFill      = Color.white.opacity(0.72)
    static let cardStroke    = Color.white.opacity(0.90)
    static let cardStroke2   = Color(red: 0.70, green: 0.80, blue: 1.00).opacity(0.45)

    static let cornerXL: CGFloat = 24
    static let cornerLg: CGFloat = 18
    static let cornerMd: CGFloat = 12
    static let cornerSm: CGFloat = 8

    static let accent        = Color(red: 0.10, green: 0.44, blue: 0.95)
    static let accentLight   = Color(red: 0.10, green: 0.44, blue: 0.95).opacity(0.10)
    static let pink          = Color(red: 0.95, green: 0.22, blue: 0.50)
    static let pinkLight     = Color(red: 0.95, green: 0.22, blue: 0.50).opacity(0.10)
    static let green         = Color(red: 0.13, green: 0.72, blue: 0.44)
    static let greenLight    = Color(red: 0.13, green: 0.72, blue: 0.44).opacity(0.10)

    static let textPrimary   = Color(red: 0.08, green: 0.10, blue: 0.18)
    static let textSecondary = Color(red: 0.35, green: 0.40, blue: 0.55)
    static let textTertiary  = Color(red: 0.55, green: 0.60, blue: 0.72)
}

// MARK: - GlassCard modifier
struct GlassCard: ViewModifier {
    var radius: CGFloat = Glass.cornerLg
    var prominent: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(Glass.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(prominent ? Glass.cardStroke : Glass.cardStroke2, lineWidth: prominent ? 1.2 : 0.8)
                    )
                    .shadow(color: Color(red: 0.55, green: 0.70, blue: 1.00).opacity(0.12), radius: 12, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
            )
    }
}

extension View {
    func glassCard(radius: CGFloat = Glass.cornerLg, prominent: Bool = false) -> some View {
        modifier(GlassCard(radius: radius, prominent: prominent))
    }

    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - Section Header
private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Glass.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Main View
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

    var body: some View {
        ZStack {
            Glass.pageBg.ignoresSafeArea()

            Circle()
                .fill(Glass.blobBlue.opacity(0.35))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -100, y: -80)
                .ignoresSafeArea()

            Circle()
                .fill(Glass.blobPurple.opacity(0.28))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: 130, y: 400)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    contentStack
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea()
        .padding(.bottom, 88)
        .overlay(alignment: .bottom) { bookingBar }
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
        .alert("Thông báo", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            if reviews.isEmpty { reviews = Self.sampleReviews }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: checkInDate) { new in
            if checkOutDate <= new {
                checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: new) ?? new
            }
        }
    }

    // MARK: - Hero
    @ViewBuilder
    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            ListingImageCarousel(listing: listing)
                .frame(height: 320)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, Glass.pageBg.opacity(0.85)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )

            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Glass.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial)
                    .overlay(Circle().stroke(Glass.cardStroke2, lineWidth: 0.8))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .padding(.leading, 16)
            .padding(.top, 58)
            .zIndex(2)
            .accessibilityIdentifier("backButtonVariantA")
        }
    }

    // MARK: - Content stack
    @ViewBuilder
    private var contentStack: some View {
        VStack(spacing: 14) {
            titleCard.padding(.top, -28)
            reviewsSection
            lineDivider
            ownerCard
            lineDivider
            featuresCard
            lineDivider
            roomSelectionCard
            lineDivider
            datepickerCard
            lineDivider
            amenitiesCard
            lineDivider
            mapCard
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 28)
    }

    private var lineDivider: some View {
        Rectangle()
            .fill(Color(red: 0.70, green: 0.80, blue: 1.00).opacity(0.25))
            .frame(height: 0.6)
            .padding(.horizontal, 8)
    }

    // MARK: - Title card
    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(listing.title)
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundStyle(Glass.textPrimary)

            HStack(spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", listing.rating))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Glass.textPrimary)
                    Text("·")
                        .foregroundStyle(Glass.textTertiary)
                    Text(reviews.isEmpty ? "Chưa có đánh giá" : "\(reviews.count) đánh giá")
                        .font(.system(size: 13))
                        .foregroundStyle(Glass.textSecondary)
                        .underline()
                }
                Spacer()
                Button(action: { withAnimation { currentReviewIndex = 0 } }) {
                    Text("Xem đánh giá")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Glass.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Glass.accentLight)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 5) {
                Image(systemName: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Glass.accent)
                Text("\(listing.city), \(listing.address)")
                    .font(.system(size: 12))
                    .foregroundStyle(Glass.textSecondary)
            }
        }
        .padding(18)
        .glassCard(prominent: true)
    }

    // MARK: - Reviews
    @ViewBuilder
    private var reviewsSection: some View {
        let displayReviews = reviews.isEmpty ? Self.sampleReviews : reviews

        VStack(spacing: 10) {
            TabView(selection: $currentReviewIndex) {
                ForEach(Array(displayReviews.enumerated()), id: \.element.id) { index, review in
                    reviewCard(review: review)
                        .padding(.horizontal, 2)
                        .tag(index)
                }
            }
            .frame(height: 172)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 5) {
                ForEach(0 ..< displayReviews.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentReviewIndex ? Glass.accent : Glass.textTertiary.opacity(0.4))
                        .frame(width: i == currentReviewIndex ? 16 : 5, height: 5)
                        .animation(.spring(response: 0.3), value: currentReviewIndex)
                }
            }

            Button { isComposingReview = true } label: {
                Label("Đánh giá & Viết nhận xét", systemImage: "pencil.line")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Glass.accent)
                    .clipShape(RoundedRectangle(cornerRadius: Glass.cornerMd))
                    .shadow(color: Glass.accent.opacity(0.28), radius: 10, x: 0, y: 5)
            }
        }
    }

    private func reviewCard(review: Review) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Glass.accentLight)
                        .overlay(Circle().stroke(Glass.cardStroke2, lineWidth: 0.8))
                        .frame(width: 40, height: 40)
                    Text(String(review.authorName.prefix(1)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Glass.accent)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(review.authorName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Glass.textPrimary)
                        Spacer()
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text(String(format: "%.1f", review.rating))
                                .font(.system(size: 12))
                                .foregroundStyle(Glass.textSecondary)
                        }
                    }
                    Text(review.comment)
                        .font(.system(size: 13))
                        .foregroundStyle(Glass.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack {
                Text(review.createdAt, style: .date)
                    .font(.system(size: 11))
                    .foregroundStyle(Glass.textTertiary)
                Spacer()
                Button { toggleLikeLocal(reviewId: review.id) } label: {
                    HStack(spacing: 4) {
                        Image(systemName: review.isLikedByCurrentUser ? "hand.thumbsup.fill" : "hand.thumbsup")
                        Text("\(review.likes)")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(review.isLikedByCurrentUser ? Glass.accent : Glass.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(review.isLikedByCurrentUser ? Glass.accentLight : Color.gray.opacity(0.08))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(review.isLikedByCurrentUser ? Glass.accent.opacity(0.3) : Color.gray.opacity(0.18), lineWidth: 0.8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .glassCard(radius: Glass.cornerMd)
    }

    // MARK: - Owner card
    private var ownerCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Chủ sở hữu")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Glass.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.6)
                Text(listing.ownerName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Glass.textPrimary)
            }
            Spacer()
            Image(listing.ownerImangUrl)
                .resizable()
                .scaledToFill()
                .frame(width: 46, height: 46)
                .clipShape(Circle())
                .overlay(Circle().stroke(Glass.cardStroke2, lineWidth: 1))
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .padding(16)
        .glassCard()
    }

    // MARK: - Features card
    private var featuresCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Đặc điểm nổi bật")
            ForEach(Array(listing.features.enumerated()), id: \.element.id) { idx, feature in
                if idx > 0 {
                    Rectangle().fill(Color(red: 0.70, green: 0.80, blue: 1.00).opacity(0.20)).frame(height: 0.6)
                }
                HStack(spacing: 12) {
                    Image(systemName: feature.imageName)
                        .font(.system(size: 16))
                        .foregroundStyle(Glass.accent)
                        .frame(width: 34, height: 34)
                        .background(Glass.accentLight)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Glass.textPrimary)
                        Text(feature.subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(Glass.textTertiary)
                    }
                    Spacer()
                }
            }
        }
        .padding(18)
        .glassCard()
    }

    // MARK: - Room selection
    @ViewBuilder
    private var roomSelectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Chọn loại phòng")
            if let roomPrices = listing.pricePerNight {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(roomPrices.keys.sorted(), id: \.self) { room in
                            let price = roomPrices[room] ?? 0
                            let isSelected = selectedRoom == room
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isSelected ? Glass.accentLight : Color.gray.opacity(0.07))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "bed.double")
                                        .font(.system(size: 18))
                                        .foregroundStyle(isSelected ? Glass.accent : Glass.textSecondary)
                                }
                                Text(room)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(isSelected ? Glass.textPrimary : Glass.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                Text("\(Int(price)) VNĐ")
                                    .font(.system(size: 10))
                                    .foregroundStyle(isSelected ? Glass.accent : Glass.textTertiary)
                            }
                            .frame(width: 108, height: 112)
                            .background(isSelected ? Glass.accentLight : Color.white.opacity(0.50))
                            .clipShape(RoundedRectangle(cornerRadius: Glass.cornerMd))
                            .overlay(
                                RoundedRectangle(cornerRadius: Glass.cornerMd)
                                    .stroke(isSelected ? Glass.accent : Glass.cardStroke2, lineWidth: isSelected ? 1.5 : 0.8)
                            )
                            .shadow(color: isSelected ? Glass.accent.opacity(0.18) : .black.opacity(0.04), radius: 8, x: 0, y: 3)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) { selectedRoom = room }
                                showRoomDetail = true
                            }
                            .onLongPressGesture { selectedRoom = room }
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .scrollTargetBehavior(.paging)
            }
        }
        .padding(18)
        .glassCard()
    }

    // MARK: - Date picker
    private var datepickerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Chọn ngày lưu trú")
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Circle().fill(Glass.green).frame(width: 7, height: 7)
                        Text("Nhận phòng")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Glass.textTertiary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    DatePicker("", selection: $checkInDate, displayedComponents: .date)
                        .labelsHidden()
                        .tint(Glass.accent)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Glass.greenLight)
                .clipShape(RoundedRectangle(cornerRadius: Glass.cornerSm))
                .overlay(RoundedRectangle(cornerRadius: Glass.cornerSm).stroke(Glass.green.opacity(0.25), lineWidth: 0.8))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Circle().fill(Glass.pink).frame(width: 7, height: 7)
                        Text("Trả phòng")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Glass.textTertiary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    DatePicker("", selection: $checkOutDate,
                               in: Calendar.current.date(byAdding: .day, value: 1, to: checkInDate)!...,
                               displayedComponents: .date)
                        .labelsHidden()
                        .tint(Glass.pink)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Glass.pinkLight)
                .clipShape(RoundedRectangle(cornerRadius: Glass.cornerSm))
                .overlay(RoundedRectangle(cornerRadius: Glass.cornerSm).stroke(Glass.pink.opacity(0.25), lineWidth: 0.8))
            }
        }
        .padding(18)
        .glassCard()
    }

    // MARK: - Amenities
    private var amenitiesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Tiện ích được cung cấp")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(listing.amenities, id: \.self) { amenity in
                    HStack(spacing: 8) {
                        Image(systemName: amenity.ImageName)
                            .font(.system(size: 13))
                            .foregroundStyle(Glass.accent)
                            .frame(width: 28, height: 28)
                            .background(Glass.accentLight)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        Text(amenity.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Glass.textSecondary)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: Glass.cornerSm))
                    .overlay(RoundedRectangle(cornerRadius: Glass.cornerSm).stroke(Glass.cardStroke2, lineWidth: 0.6))
                }
            }
        }
        .padding(18)
        .glassCard()
    }

    // MARK: - Map
    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Địa điểm")
            Map(position: $showMap)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: Glass.cornerMd))
                .overlay(RoundedRectangle(cornerRadius: Glass.cornerMd).stroke(Glass.cardStroke2, lineWidth: 0.8))
            HStack(spacing: 5) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(Glass.accent)
                Text("\(listing.city), \(listing.address)")
                    .font(.system(size: 12))
                    .foregroundStyle(Glass.textSecondary)
            }
        }
        .padding(18)
        .glassCard()
    }

    // MARK: - Booking bar
    private var bookingBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(red: 0.70, green: 0.80, blue: 1.00).opacity(0.30))
                .frame(height: 0.6)
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    if let selectedRoom = selectedRoom, let price = listing.pricePerNight?[selectedRoom] {
                        Text("\(Int(price)) VNĐ")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Glass.textPrimary)
                        Text("mỗi đêm")
                            .font(.system(size: 11))
                            .foregroundStyle(Glass.textTertiary)
                        Text(selectedRoom)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Glass.pink)
                    } else {
                        Text("Chưa chọn phòng")
                            .font(.system(size: 13))
                            .foregroundStyle(Glass.textTertiary)
                    }
                }

                NavigationLink(destination: HistoryView(), isActive: $navigateToHistory) {
                    EmptyView()
                }

                Button(action: { Task { await placeBooking() } }) {
                    HStack(spacing: 6) {
                        if isProcessing {
                            ProgressView().tint(.white).scaleEffect(0.82)
                        }
                        Text(isProcessing ? "Đang xử lý..." : "Thanh toán")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        isProcessing || selectedRoom == nil
                            ? Color.gray.opacity(0.35)
                            : Glass.accent
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Glass.cornerMd))
                    .shadow(
                        color: (selectedRoom != nil && !isProcessing) ? Glass.accent.opacity(0.30) : .clear,
                        radius: 10, x: 0, y: 5
                    )
                }
                .disabled(isProcessing || selectedRoom == nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Local helpers (unchanged logic)
    private func toggleLikeLocal(reviewId: String) {
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
        var samples = Self.sampleReviews
        if let sIdx = samples.firstIndex(where: { $0.id == reviewId }) {
            if samples[sIdx].isLikedByCurrentUser {
                samples[sIdx].isLikedByCurrentUser = false
                samples[sIdx].likes = max(0, samples[sIdx].likes - 1)
            } else {
                samples[sIdx].isLikedByCurrentUser = true
                samples[sIdx].likes += 1
            }
            reviews = samples
        }
    }

    // MARK: - Place booking (unchanged logic)
    private func placeBooking() async {
        if isProcessing { return }
        await MainActor.run { isProcessing = true }
        guard let selectedRoom = selectedRoom, let price = listing.pricePerNight?[selectedRoom] else {
            await MainActor.run { alertMessage = "Vui lòng chọn loại phòng trước khi thanh toán."; showAlert = true; isProcessing = false }
            return
        }
        guard checkOutDate > checkInDate else {
            await MainActor.run { alertMessage = "Ngày trả phòng phải sau ngày nhận phòng."; showAlert = true; isProcessing = false }
            return
        }
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                await MainActor.run { alertMessage = "Bạn cần đăng nhập để đặt phòng."; showAlert = true; isProcessing = false }
                return
            }
            let db = Firestore.firestore()
            let bookingRef = db.collection("bookings").document()
            let bookingData: [String: Any] = [
                "userId": userId,
                "hotelId": listing.id,
                "hotelName": listing.title,
                "hotelAddress": listing.address,
                "roomType": selectedRoom,
                "price": price,
                "currency": "VND",
                "checkIn": Timestamp(date: checkInDate),
                "checkOut": Timestamp(date: checkOutDate),
                "createdAt": Timestamp(date: Date())
            ]
            try await bookingRef.setData(bookingData)
            await MainActor.run {
                NotificationCenter.default.post(name: .didCreateBooking, object: nil, userInfo: [
                    "bookingId": bookingRef.documentID,
                    "hotelId": listing.id,
                    "roomType": selectedRoom,
                    "price": price,
                    "checkIn": checkInDate,
                    "checkOut": checkOutDate
                ])
                isProcessing = false
                navigateToHistory = true
            }
        } catch {
            await MainActor.run { alertMessage = "Đã có lỗi xảy ra khi đặt phòng. Vui lòng thử lại."; showAlert = true; isProcessing = false }
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

    // MARK: - RoomDetailView (light glass)
    struct RoomDetailView: View {
        let roomName: String
        let price: Double
        let listing: Listing

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
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Glass.cardStroke2, lineWidth: 0.8))
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
                                Text("VNĐ / đêm")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Glass.textSecondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "text.alignleft").foregroundStyle(Glass.accent)
                                Text("Mô tả phòng")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Glass.textPrimary)
                            }
                            Text("Phòng khách sạn được thiết kế theo phong cách hiện đại và sang trọng, mang lại cảm giác ấm cúng nhưng vẫn đầy đủ tiện nghi. Không gian phòng rộng rãi với giường lớn êm ái, chăn ga sạch sẽ và ánh đèn vàng dịu nhẹ tạo cảm giác thư giãn cho khách lưu trú. Cửa sổ lớn giúp đón ánh sáng tự nhiên và mở ra khung cảnh đẹp của thành phố. Trong phòng được trang bị đầy đủ các tiện ích như điều hòa, tivi màn hình phẳng, wifi tốc độ cao, minibar và bàn làm việc.")
                                .font(.system(size: 14))
                                .foregroundStyle(Glass.textSecondary)
                                .lineSpacing(5)
                        }
                        .padding(18)
                        .glassCard()
                        .padding(.horizontal, 16)

                        Spacer(minLength: 32)
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }

    #Preview {
        ListingDetailView(listing: DeveloperPreview.shared.listings[0])
    }
}
