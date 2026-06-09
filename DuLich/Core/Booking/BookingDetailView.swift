// BookingDetailView.swift
import SwiftUI
import MapKit
import Combine
import FirebaseAuth
struct BookingDetailView: View {
    let booking: DBBooking?
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
                ProgressView("loading")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let err = vm.errorMessage {
                VStack(spacing: 12) {
                    Text("error_with_message \(err)").foregroundColor(.red)
                    Button("retry") { Task { await vm.load(booking: booking, bookingId: bookingId) } }
                }
                .padding()
            } else {
                VStack(spacing: 12) {
                    Text("no_booking_info")
                        .foregroundColor(.secondary)
                    Button("reload") { Task { await vm.load(booking: booking, bookingId: bookingId) } }
                }
                .padding()
            }
        }
        .navigationTitle("booking_detail_title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if vm.isCancelling {
                    ProgressView()
                } else if vm.canCancel {
                    Button(role: .destructive) {
                        vm.showCancelConfirm = true
                    } label: {
                        Text("cancel_booking_btn")
                    }
                    .disabled(vm.booking == nil)
                }
            }
        }
        .onAppear {
            vm.refreshReferenceDate()
            Task { await vm.load(booking: booking, bookingId: bookingId) }
        }
        .alert("confirm_title", isPresented: $vm.showCancelConfirm) {
            Button(String(localized: "cancel_room"), role: .destructive) {
                Task { await vm.cancelBooking() }
            }
            Button("can_cel", role: .cancel) {}
        } message: {
            Text("cancel_booking_message")
        }
        .alert("check_in_confirm_title", isPresented: $vm.showCheckInConfirm) {
            Button("check_in_confirm_yes", role: .none) {
                Task { await vm.confirmCheckIn() }
            }
            Button("check_in_confirm_cancel", role: .cancel) {}
        } message: {
            Text("check_in_confirm_message")
        }
        .alert("notification_title", isPresented: $vm.showInfoAlert) {
            Button("OK") {
                if vm.didCancelSuccessfully || vm.didCheckInSuccessfully {
                    dismiss()
                }
            }
        } message: {
            Text(vm.infoMessage ?? "")
        }
    }

    @ViewBuilder
    private func statusCard(for booking: DBBooking) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("status_label")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                Text(booking.status.displayName)
                    .font(.headline)
                    .foregroundColor(statusColor(for: booking))
                Spacer()
                if booking.cancelReason == "no_show" {
                    Text("no_show_reason")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            if let checkedInAt = booking.checkedInAt {
                Text("checked_in_at \(Self.createdFormatter.string(from: checkedInAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func statusColor(for booking: DBBooking) -> Color {
        switch booking.status {
        case .active: return .orange
        case .checkedIn: return .green
        case .cancelled: return .red
        }
    }

    @ViewBuilder
    private func content(for booking: DBBooking) -> some View {
        ScrollView {
            VStack(spacing: 16) {
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

                VStack(alignment: .leading, spacing: 6) {
                    Text("check_in_date_label").font(.caption).foregroundColor(.secondary)
                    Text(Self.dateFormatter.string(from: booking.checkIn))
                        .font(.body)
                    Text("check_out_date_label").font(.caption).foregroundColor(.secondary)
                    Text(Self.dateFormatter.string(from: booking.checkOut))
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
                .cornerRadius(12)

                statusCard(for: booking)

                if booking.status == .active && BookingManager.isCheckInDay(checkIn: booking.checkIn, referenceDate: vm.referenceDate) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundColor(.orange)
                        Text("check_in_reminder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                if !vm.canCancel && booking.status == .active {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("cancel_deadline_warning \(BookingManager.cancellationDeadlineDays)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Created at and meta
                VStack(alignment: .leading, spacing: 6) {
                    if let created = booking.createdAt {
                        Text("booked_at \(Self.createdFormatter.string(from: created))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("booking_id_label \(booking.id)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                if let lat = vm.latitude, let lon = vm.longitude {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), interactionModes: [])
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }

                if let meta = vm.meta, !meta.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("booker_info").font(.headline)
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

                Spacer(minLength: vm.canConfirmCheckIn ? 88 : 24)
            }
            .padding(.vertical)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if vm.canConfirmCheckIn {
                checkInButton
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(.bar)
            }
        }
    }

    private var checkInButton: some View {
        Button {
            vm.showCheckInConfirm = true
        } label: {
            HStack(spacing: 8) {
                if vm.isConfirmingCheckIn {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "door.left.hand.open")
                    Text("check_in_btn")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(Color(red: 0.13, green: 0.72, blue: 0.44))
            .cornerRadius(12)
        }
        .disabled(vm.isConfirmingCheckIn)
    }

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

@MainActor
final class BookingDetailViewModel: ObservableObject {
    @Published var booking: DBBooking? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @Published var isCancelling: Bool = false
    @Published var isConfirmingCheckIn: Bool = false
    @Published var showCancelConfirm: Bool = false
    @Published var showCheckInConfirm: Bool = false
    @Published var showInfoAlert: Bool = false
    @Published var infoMessage: String? = nil
    @Published var didCancelSuccessfully: Bool = false
    @Published var didCheckInSuccessfully: Bool = false

    @Published var meta: [String: Any]? = nil
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    @Published private(set) var referenceDate: Date = Date()

    var canCancel: Bool {
        guard let booking else { return false }
        return booking.status == .active
            && BookingManager.canCancelBooking(checkIn: booking.checkIn, referenceDate: referenceDate)
    }

    var canConfirmCheckIn: Bool {
        guard let booking else { return false }
        return BookingManager.canConfirmCheckIn(booking: booking, referenceDate: referenceDate)
    }

    func refreshReferenceDate() {
        referenceDate = Date()
    }

    func load(booking: DBBooking?, bookingId: String?) async {
        isLoading = booking == nil && bookingId != nil
        errorMessage = nil
        defer { isLoading = false }

        refreshReferenceDate()

        let idToFetch = booking?.id ?? bookingId
        guard let id = idToFetch else {
            errorMessage = String(localized: "no_booking_displayed")
            return
        }

        do {
            if let fetched = try await fetchBookingById(id: id) {
                self.booking = fetched
                parseMeta(from: fetched)
            } else if let fallback = booking {
                self.booking = fallback
                parseMeta(from: fallback)
            } else {
                errorMessage = String(localized: "booking_not_found")
            }
        } catch {
            if let fallback = booking {
                self.booking = fallback
                parseMeta(from: fallback)
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    func confirmCheckIn() async {
        guard let currentBooking = booking else { return }
        guard BookingManager.canConfirmCheckIn(booking: currentBooking) else {
            infoMessage = BookingError.checkInNotToday.localizedDescription
            didCheckInSuccessfully = false
            showInfoAlert = true
            return
        }

        isConfirmingCheckIn = true
        defer { isConfirmingCheckIn = false }

        do {
            try await BookingManager.shared.confirmCheckIn(bookingId: currentBooking.id)
            booking = DBBooking(
                id: currentBooking.id,
                userId: currentBooking.userId,
                hotelId: currentBooking.hotelId,
                hotelName: currentBooking.hotelName,
                hotelAddress: currentBooking.hotelAddress,
                roomType: currentBooking.roomType,
                price: currentBooking.price,
                currency: currentBooking.currency,
                checkIn: currentBooking.checkIn,
                checkOut: currentBooking.checkOut,
                createdAt: currentBooking.createdAt,
                roomNumber: currentBooking.roomNumber,
                status: .checkedIn,
                checkedInAt: Date(),
                cancelReason: nil
            )
            infoMessage = String(localized: "check_in_confirmed_message")
            didCheckInSuccessfully = true
            showInfoAlert = true
            NotificationCenter.default.post(name: .didUpdateBooking, object: nil)
        } catch {
            infoMessage = error.localizedDescription
            didCheckInSuccessfully = false
            showInfoAlert = true
        }
    }

    func cancelBooking() async {
        guard let currentBooking = booking else { return }
        guard BookingManager.canCancelBooking(checkIn: currentBooking.checkIn) else {
            infoMessage = BookingError.cancellationTooLate(daysRequired: BookingManager.cancellationDeadlineDays).localizedDescription
            didCancelSuccessfully = false
            showInfoAlert = true
            return
        }

        isCancelling = true
        defer { isCancelling = false }

        do {
            try await BookingManager.shared.cancelBooking(bookingId: currentBooking.id)
            booking = DBBooking(
                id: currentBooking.id,
                userId: currentBooking.userId,
                hotelId: currentBooking.hotelId,
                hotelName: currentBooking.hotelName,
                hotelAddress: currentBooking.hotelAddress,
                roomType: currentBooking.roomType,
                price: currentBooking.price,
                currency: currentBooking.currency,
                checkIn: currentBooking.checkIn,
                checkOut: currentBooking.checkOut,
                createdAt: currentBooking.createdAt,
                roomNumber: currentBooking.roomNumber,
                status: .cancelled,
                checkedInAt: currentBooking.checkedInAt,
                cancelReason: "user"
            )
            infoMessage = String(localized:"successfully_cancelled")
            didCancelSuccessfully = true
            showInfoAlert = true
            NotificationCenter.default.post(name: .didUpdateBooking, object: nil)
        } catch {
            infoMessage = error.localizedDescription
            didCancelSuccessfully = false
            showInfoAlert = true
        }
    }


    private func parseMeta(from booking: DBBooking) {
        self.meta = nil
        if let m = self.meta {
            if let lat = m["lat"] as? Double ?? (m["latitude"] as? Double),
               let lon = m["lng"] as? Double ?? (m["longitude"] as? Double) {
                self.latitude = lat
                self.longitude = lon
            }
        }
    }

    private func fetchBookingById(id: String) async throws -> DBBooking? {
        if let uid = Auth.auth().currentUser?.uid {
            let items = try await BookingManager.shared.fetchBookings(forUserId: uid)
            return items.first(where: { $0.id == id })
        } else {
            return nil
        }
    }
}
