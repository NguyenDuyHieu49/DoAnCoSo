import SwiftUI
import MapKit

extension Notification.Name {
    static let didCreateBooking = Notification.Name("didCreateBooking")
}

struct ListingDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ListingDetailViewModel()
    let listing: Listing

    @State private var showMap: MapCameraPosition
    @State private var showRoomDetail: Bool = false
    @State private var isComposingReview: Bool = false

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
            if let room = viewModel.selectedRoom, let price = listing.pricePerNight?[room] {
                RoomDetailView(roomName: room, price: Double(price), listing: listing)
            }
        }
        .sheet(isPresented: $isComposingReview) {
            ReviewComposerView { authorName, rating, comment in
                viewModel.submitReview(authorName: authorName, rating: rating, comment: comment)
                isComposingReview = false
            }
        }
        .alert("Thông báo", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
        .onAppear {
            if viewModel.reviews.isEmpty {
                viewModel.reviews = ListingDetailViewModel.sampleReviews
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.checkInDate) { new in
            if viewModel.checkOutDate <= new {
                viewModel.checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: new) ?? new
            }
        }
    }

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
            .padding(.leading, 16)
            .padding(.top, 58)
            .zIndex(2)
        }
    }

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

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(listing.title)
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundStyle(Glass.textPrimary)
            HStack(spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill").font(.caption).foregroundStyle(.orange)
                    Text(String(format: "%.1f", listing.rating))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Glass.textPrimary)
                    Text("·").foregroundStyle(Glass.textTertiary)
                    Text(viewModel.reviews.isEmpty ? "Chưa có đánh giá" : "\(viewModel.reviews.count) đánh giá")
                        .font(.system(size: 13))
                        .foregroundStyle(Glass.textSecondary)
                        .underline()
                }
                Spacer()
                Button { withAnimation { viewModel.currentReviewIndex = 0 } } label: {
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
                Image(systemName: "mappin.circle.fill").font(.caption).foregroundStyle(Glass.accent)
                Text("\(listing.city), \(listing.address)")
                    .font(.system(size: 12))
                    .foregroundStyle(Glass.textSecondary)
            }
        }
        .padding(18)
        .glassCard(prominent: true)
    }

    private var reviewsSection: some View {
        let displayReviews = viewModel.reviews.isEmpty ? ListingDetailViewModel.sampleReviews : viewModel.reviews
        return VStack(spacing: 10) {
            TabView(selection: $viewModel.currentReviewIndex) {
                ForEach(Array(displayReviews.enumerated()), id: \.element.id) { index, review in
                    reviewCard(review: review).padding(.horizontal, 2).tag(index)
                }
            }
            .frame(height: 172)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 5) {
                ForEach(0..<displayReviews.count, id: \.self) { i in
                    Capsule()
                        .fill(i == viewModel.currentReviewIndex ? Glass.accent : Glass.textTertiary.opacity(0.4))
                        .frame(width: i == viewModel.currentReviewIndex ? 16 : 5, height: 5)
                        .animation(.spring(response: 0.3), value: viewModel.currentReviewIndex)
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
                            Image(systemName: "star.fill").font(.caption2).foregroundStyle(.orange)
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
                Button { viewModel.toggleLike(reviewId: review.id) } label: {
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
            AsyncImage(url: URL(string: listing.ownerImangUrl)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle().fill(Color(white: 0.85))
                        .overlay(Image(systemName: "person.fill").foregroundColor(Color(white: 0.6)))
                }
            }
            .frame(width: 46, height: 46)
            .clipShape(Circle())
            .overlay(Circle().stroke(Glass.cardStroke2, lineWidth: 1))
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .padding(16)
        .glassCard()
    }

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

    private var roomSelectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Chọn loại phòng")
            if let roomPrices = listing.pricePerNight {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(roomPrices.keys.sorted(), id: \.self) { room in
                            let price = roomPrices[room] ?? 0
                            let isSelected = viewModel.selectedRoom == room
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
                                withAnimation(.spring(response: 0.3)) { viewModel.selectedRoom = room }
                                showRoomDetail = true
                            }
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
                    DatePicker("", selection: $viewModel.checkInDate, displayedComponents: .date)
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
                    DatePicker("", selection: $viewModel.checkOutDate,
                               in: Calendar.current.date(byAdding: .day, value: 1, to: viewModel.checkInDate)!...,
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

    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Địa điểm")
            Map(position: $showMap)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: Glass.cornerMd))
                .overlay(RoundedRectangle(cornerRadius: Glass.cornerMd).stroke(Glass.cardStroke2, lineWidth: 0.8))
            HStack(spacing: 5) {
                Image(systemName: "mappin.and.ellipse").font(.caption).foregroundStyle(Glass.accent)
                Text("\(listing.city), \(listing.address)")
                    .font(.system(size: 12))
                    .foregroundStyle(Glass.textSecondary)
            }
        }
        .padding(18)
        .glassCard()
    }

    private var bookingBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(red: 0.70, green: 0.80, blue: 1.00).opacity(0.30))
                .frame(height: 0.6)
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    if let room = viewModel.selectedRoom, let price = listing.pricePerNight?[room] {
                        Text("\(Int(price)) VNĐ")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Glass.textPrimary)
                        Text("mỗi đêm")
                            .font(.system(size: 11))
                            .foregroundStyle(Glass.textTertiary)
                        Text(room)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Glass.pink)
                    } else {
                        Text("Chưa chọn phòng")
                            .font(.system(size: 13))
                            .foregroundStyle(Glass.textTertiary)
                    }
                }

                NavigationLink(destination: HistoryView(), isActive: $viewModel.navigateToHistory) {
                    EmptyView()
                }

                Button { Task { await viewModel.placeBooking(listing: listing) } } label: {
                    HStack(spacing: 6) {
                        if viewModel.isProcessing {
                            ProgressView().tint(.white).scaleEffect(0.82)
                        }
                        Text(viewModel.isProcessing ? "Đang xử lý..." : "Thanh toán")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        viewModel.isProcessing || viewModel.selectedRoom == nil
                            ? Color.gray.opacity(0.35)
                            : Glass.accent
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Glass.cornerMd))
                    .shadow(
                        color: (viewModel.selectedRoom != nil && !viewModel.isProcessing) ? Glass.accent.opacity(0.30) : .clear,
                        radius: 10, x: 0, y: 5
                    )
                }
                .disabled(viewModel.isProcessing || viewModel.selectedRoom == nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    ListingDetailView(listing: DeveloperPreview.shared.listings[0])
}
