// HistoryView.swift
import SwiftUI
import FirebaseFirestore

struct HistoryView: View {
    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.75, blue: 1.0),
                        Color(red: 0.75, green: 0.88, blue: 1.0),
                        Color(red: 0.88, green: 0.93, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(Color.white.opacity(0.32))
                    .frame(width: 260, height: 260)
                    .blur(radius: 60)
                    .offset(x: -110, y: -180)

                Circle()
                    .fill(Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.25))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: 130, y: 220)

                Group {
                    if vm.isLoading {
                        loadingView
                    } else if let err = vm.errorMessage {
                        errorView(err)
                    } else if vm.bookings.isEmpty {
                        emptyView
                    } else {
                        bookingListView
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Lịch sử đặt phòng")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                Task { await vm.load() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .didCreateBooking)) { _ in
                Task { await vm.load() }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 72, height: 72)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
            }
            Text("Đang tải...")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 80, height: 80)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 34, weight: .light))
                    .foregroundColor(.white)
            }
            VStack(spacing: 8) {
                Text("Đã xảy ra lỗi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(message)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            glassButton(title: "Thử lại", icon: "arrow.clockwise") {
                Task { await vm.load() }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 90, height: 90)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.white)
            }
            VStack(spacing: 8) {
                Text("Chưa có lịch sử")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Bạn chưa đặt phòng nào.\nHãy bắt đầu khám phá!")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            glassButton(title: "reload", icon: "arrow.clockwise") {
                Task { await vm.load() }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var bookingListView: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(vm.bookings) { booking in
                    NavigationLink(destination: BookingDetailView(booking: booking)) {
                        BookingRowCard(booking: booking)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .refreshable { await vm.load() }
    }

    private func glassButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 13)
            .background(
                ZStack {
                    Capsule().fill(Color.white.opacity(0.22))
                    Capsule().strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                }
            )
            .shadow(color: Color.blue.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}

struct BookingRowCard: View {
    let booking: DBBooking

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.18))

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.45, blue: 0.95),
                                    Color(red: 0.35, green: 0.6, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.white.opacity(0)],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white)
                }
                .shadow(color: Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.35), radius: 6, x: 0, y: 3)

                VStack(alignment: .leading, spacing: 5) {
                    Text(booking.hotelName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.25))
                        .lineLimit(1)

                    Text(booking.roomType)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.8))
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.7))
                        Text(Self.dateFormatter.string(from: booking.checkIn))
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.7))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(Int(booking.price))")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.25))

                    Text(booking.currency)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.7))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.55))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .shadow(color: Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.12), radius: 12, x: 0, y: 6)
    }
}
