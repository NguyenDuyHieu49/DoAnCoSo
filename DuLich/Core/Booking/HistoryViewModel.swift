// HistoryViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var bookings: [DBBooking] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private var notificationToken: NSObjectProtocol?

    init() {
        // Listen for booking creation notifications so we can insert the new booking immediately
        notificationToken = NotificationCenter.default.addObserver(
            forName: .didCreateBooking,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self = self else { return }
            if let bookingId = note.userInfo?["bookingId"] as? String {
                Task { await self.insertBookingById(bookingId) }
            } else {
                Task { await self.load() }
            }
        }
    }

    deinit {
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    /// Load all bookings for current user and sort client-side by `createdAt` descending.
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let uid = Auth.auth().currentUser?.uid else {
            bookings = []
            errorMessage = "Người dùng chưa đăng nhập."
            return
        }

        do {
            let snapshot = try await db.collection("bookings")
                .whereField("userId", isEqualTo: uid)
                .getDocuments()

            var items: [DBBooking] = []
            items.reserveCapacity(snapshot.documents.count)

            for doc in snapshot.documents {
                if let manual = try? manualDecode(doc: doc) {
                    items.append(manual)
                } else {
                    print("Warning: unable to decode booking doc \(doc.documentID)")
                }
            }

            // Sort descending by createdAt (fallback to distantPast if missing)
            bookings = items.sorted {
                let aDate = $0.createdAt ?? Date.distantPast
                let bDate = $1.createdAt ?? Date.distantPast
                return aDate > bDate
            }
        } catch {
            errorMessage = "Lỗi khi tải lịch sử: \(error.localizedDescription)"
            bookings = []
        }
    }

    /// Insert a single booking by id at the top of the list (fetches from server)
    private func insertBookingById(_ bookingId: String) async {
        do {
            // Try fetch document directly
            let doc = try await db.collection("bookings").document(bookingId).getDocument()
            if let booking = try? manualDecode(doc: doc) {
                upsertBooking(booking)
            } else {
                // fallback: reload full list
                await load()
            }
        } catch {
            print("Không fetch được booking mới: \(error.localizedDescription)")
            await load()
        }
    }

    /// Upsert booking into local array (avoid duplicates)
    private func upsertBooking(_ booking: DBBooking) {
        if let idx = bookings.firstIndex(where: { $0.id == booking.id }) {
            bookings[idx] = booking
        } else {
            bookings.insert(booking, at: 0)
        }
    }

    // Manual decode from DocumentSnapshot -> DBBooking
    private func manualDecode(doc: DocumentSnapshot) throws -> DBBooking? {
        let data = doc.data() ?? [:]

        // Required fields
        guard let userId = data["userId"] as? String else { return nil }
        guard let hotelId = data["hotelId"] as? String else { return nil }
        guard let hotelName = data["hotelName"] as? String else { return nil }

        let id = doc.documentID
        let hotelAddress = data["hotelAddress"] as? String
        let roomType = data["roomType"] as? String ?? "Unknown"

        let price: Double
        if let d = data["price"] as? Double { price = d }
        else if let n = data["price"] as? NSNumber { price = n.doubleValue }
        else if let i = data["price"] as? Int { price = Double(i) }
        else { price = 0 }

        let currency = data["currency"] as? String ?? "VND"

        // Dates: support Timestamp or Date
        let checkIn: Date
        if let ts = data["checkIn"] as? Timestamp { checkIn = ts.dateValue() }
        else if let d = data["checkIn"] as? Date { checkIn = d }
        else { checkIn = Date() }

        let checkOut: Date
        if let ts = data["checkOut"] as? Timestamp { checkOut = ts.dateValue() }
        else if let d = data["checkOut"] as? Date { checkOut = d }
        else { checkOut = Calendar.current.date(byAdding: .day, value: 1, to: checkIn) ?? Date() }

        let createdAt: Date?
        if let ts = data["createdAt"] as? Timestamp { createdAt = ts.dateValue() }
        else if let d = data["createdAt"] as? Date { createdAt = d }
        else { createdAt = nil }

        // Build DBBooking using your initializer
        let booking = DBBooking(
            id: id,
            userId: userId,
            hotelId: hotelId,
            hotelName: hotelName,
            hotelAddress: hotelAddress,
            roomType: roomType,
            price: price,
            currency: currency,
            checkIn: checkIn,
            checkOut: checkOut,
            createdAt: createdAt
        )
        return booking
    }
}
