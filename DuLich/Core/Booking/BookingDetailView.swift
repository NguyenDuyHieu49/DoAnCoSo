// BookingDetailView.swift
import SwiftUI
import MapKit
import Combine
import FirebaseAuth
/// A view that displays details for a booking (DBBooking).
/// Accepts either a DBBooking instance or a bookingId to fetch the booking.
/// Requires BookingManager with `cancelBooking(bookingId:)` and optionally
/// a fetch-by-id method if you want to initialize with an id.
struct BookingDetailView: View {
    // Provide either `booking` or `bookingId`. If both provided, `booking` is used.
    let booking: DBBooking?

    // Optional: if you only have an id, set bookingId and the view will try to fetch it.
    let bookingId: String?

    @StateObject private var vm = BookingDetailViewModel()

    @Environment(\.dismiss) private var dismiss

    init(booking: DBBooking) {
        self.booking = booking
        self.bookingId = nil
    }

    init(bookingId: String) {
        self.booking = nil
        self.bookingId = bookingId
    }

    var body: some View {
        Group {
            if let model = vm.booking {
                content(for: model)
            } else if vm.isLoading {
                ProgressView("Đang tải...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let err = vm.errorMessage {
                VStack(spacing: 12) {
                    Text("Lỗi: \(err)").foregroundColor(.red)
                    Button("Thử lại") { Task { await vm.load(booking: booking, bookingId: bookingId) } }
                }
                .padding()
            } else {
                // No booking yet: try to load
                VStack(spacing: 12) {
                    Text("Không có thông tin đặt phòng")
                        .foregroundColor(.secondary)
                    Button("Tải lại") { Task { await vm.load(booking: booking, bookingId: bookingId) } }
                }
                .padding()
            }
        }
        .navigationTitle("Chi tiết đặt phòng")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if vm.isCancelling {
                    ProgressView()
                } else {
                    Button(role: .destructive) {
                        vm.showCancelConfirm = true
                    } label: {
                        Text("Huỷ đặt")
                    }
                    .disabled(vm.booking == nil)
                }
            }
        }
        .onAppear {
            Task { await vm.load(booking: booking, bookingId: bookingId) }
        }
        .alert("Xác nhận", isPresented: $vm.showCancelConfirm) {
            Button("Huỷ đặt", role: .destructive) {
                Task { await vm.cancelBooking() }
            }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Bạn có chắc muốn huỷ đặt phòng này không?")
        }
        .alert("Thông báo", isPresented: $vm.showInfoAlert) {
            Button("OK") { if vm.didCancelSuccessfully { dismiss() } }
        } message: {
            Text(vm.infoMessage ?? "")
        }
    }

    @ViewBuilder
    private func content(for booking: DBBooking) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Hotel / place info
                VStack(alignment: .leading, spacing: 8) {
                    Text(booking.hotelName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if let addr = booking.hotelAddress {
                        Text(addr)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text(booking.roomType)
                            .font(.subheadline)
                            .padding(6)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        Spacer()
                        Text("\(Int(booking.price)) \(booking.currency)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                // Dates
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ngày nhận phòng").font(.caption).foregroundColor(.secondary)
                    Text(Self.dateFormatter.string(from: booking.checkIn))
                        .font(.body)
                    Text("Ngày trả phòng").font(.caption).foregroundColor(.secondary)
                    Text(Self.dateFormatter.string(from: booking.checkOut))
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
                .cornerRadius(12)

                // Created at and meta
                VStack(alignment: .leading, spacing: 6) {
                    if let created = booking.createdAt {
                        Text("Đặt lúc: \(Self.createdFormatter.string(from: created))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("Mã đặt: \(booking.id)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Map preview if coordinates exist in meta
                if let lat = vm.latitude, let lon = vm.longitude {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), interactionModes: [])
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }

                // User info (if stored in meta)
                if let meta = vm.meta, !meta.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Thông tin người đặt").font(.headline)
                        ForEach(meta.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack {
                                Text(key).font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Text("\(String(describing: value))").font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer(minLength: 24)
            }
            .padding(.vertical)
        }
    }

    // Date formatters
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    private static let createdFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()
}

// MARK: - ViewModel for BookingDetailView
@MainActor
final class BookingDetailViewModel: ObservableObject {
    @Published var booking: DBBooking? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @Published var isCancelling: Bool = false
    @Published var showCancelConfirm: Bool = false
    @Published var showInfoAlert: Bool = false
    @Published var infoMessage: String? = nil
    @Published var didCancelSuccessfully: Bool = false

    // optional parsed meta
    @Published var meta: [String: Any]? = nil
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil

    /// Load either from provided booking or fetch by id
    func load(booking: DBBooking?, bookingId: String?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        if let b = booking {
            self.booking = b
            parseMeta(from: b)
            return
        }

        guard let id = bookingId else {
            errorMessage = "Không có booking để hiển thị."
            return
        }

        do {
            // If you have a fetch-by-id method, call it. Otherwise fetch all and find by id.
            // Try to use BookingManager.shared.fetchBooking(bookingId:) if available.
            if let fetched = try await fetchBookingById(id: id) {
                self.booking = fetched
                parseMeta(from: fetched)
            } else {
                errorMessage = "Không tìm thấy booking."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Cancel booking
    func cancelBooking() async {
        guard let id = booking?.id else { return }
        isCancelling = true
        defer { isCancelling = false }

        do {
            try await BookingManager.shared.cancelBooking(bookingId: id)
            infoMessage = "Huỷ đặt phòng thành công."
            didCancelSuccessfully = true
            showInfoAlert = true
        } catch {
            infoMessage = "Huỷ thất bại: \(error.localizedDescription)"
            didCancelSuccessfully = false
            showInfoAlert = true
        }
    }

    // MARK: - Helpers

    private func parseMeta(from booking: DBBooking) {
        // If DBBooking has a meta dictionary, extract it. This depends on your DBBooking implementation.
        // Here we attempt to read a `meta` property via reflection or if DBBooking exposes it.
        // If DBBooking doesn't expose meta, you can modify DBBooking to include a meta field.
        self.meta = nil
        // Example: if DBBooking had a `meta` property:
        // self.meta = booking.meta

        // Try to parse coordinates from meta keys "lat" / "lng" or "latitude"/"longitude"
        if let m = self.meta {
            if let lat = m["lat"] as? Double ?? (m["latitude"] as? Double),
               let lon = m["lng"] as? Double ?? (m["longitude"] as? Double) {
                self.latitude = lat
                self.longitude = lon
            }
        }
    }

    /// Fallback fetch: try to fetch bookings for current user and find by id.
    private func fetchBookingById(id: String) async throws -> DBBooking? {
        // If BookingManager has a direct fetch-by-id, use it. Otherwise fetch user's bookings.
        // This implementation tries to fetch all bookings for current user and find the id.
        if let uid = Auth.auth().currentUser?.uid {
            let items = try await BookingManager.shared.fetchBookings(forUserId: uid)
            return items.first(where: { $0.id == id })
        } else {
            return nil
        }
    }
}
