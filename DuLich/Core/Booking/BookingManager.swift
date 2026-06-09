// BookingManager.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

enum BookingError: LocalizedError {
    case cancellationTooLate(daysRequired: Int)
    case notFound
    case checkInNotToday
    case alreadyCheckedIn
    case notActive

    var errorDescription: String? {
        switch self {
        case .cancellationTooLate(let days):
            return String(localized: "booking_error_cancellation_too_late \(days)")
        case .notFound:
            return String(localized: "booking_error_not_found")
        case .checkInNotToday:
            return String(localized: "booking_error_check_in_not_today")
        case .alreadyCheckedIn:
            return String(localized: "booking_error_already_checked_in")
        case .notActive:
            return String(localized: "booking_error_not_active")
        }
    }
}

final class BookingManager {
    static let shared = BookingManager()
    static let cancellationDeadlineDays = 7

    private let db = Firestore.firestore()
    private init() {}

    static func canCancelBooking(checkIn: Date, referenceDate: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        let checkInDay = calendar.startOfDay(for: checkIn)
        guard let deadline = calendar.date(byAdding: .day, value: -cancellationDeadlineDays, to: checkInDay) else {
            return false
        }
        return today <= deadline
    }

    static func isCheckInDay(checkIn: Date, referenceDate: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(
            calendar.startOfDay(for: checkIn),
            inSameDayAs: calendar.startOfDay(for: referenceDate)
        )
    }

    static func canConfirmCheckIn(booking: DBBooking, referenceDate: Date = Date()) -> Bool {
        booking.status == .active
            && booking.checkedInAt == nil
            && isCheckInDay(checkIn: booking.checkIn, referenceDate: referenceDate)
    }

    static func shouldAutoCancelForNoShow(booking: DBBooking, referenceDate: Date = Date()) -> Bool {
        guard booking.status == .active, booking.checkedInAt == nil else { return false }
        let calendar = Calendar.current
        let checkInDay = calendar.startOfDay(for: booking.checkIn)
        let today = calendar.startOfDay(for: referenceDate)
        return today > checkInDay
    }

    func createBooking(hotelId: String,
                       hotelName: String,
                       hotelAddress: String?,
                       roomType: String,
                       price: Double,
                       currency: String = "VND",
                       checkIn: Date,
                       checkOut: Date,
                       meta: [String: Any] = [:]) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "BookingManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        var data: [String: Any] = [
            "userId": uid,
            "hotelId": hotelId,
            "hotelName": hotelName,
            "hotelAddress": hotelAddress as Any,
            "roomType": roomType,
            "price": price,
            "currency": currency,
            "checkIn": Timestamp(date: checkIn),
            "checkOut": Timestamp(date: checkOut),
            "createdAt": FieldValue.serverTimestamp()
        ]

        meta.forEach { data[$0.key] = $0.value }

        let ref = try await db.collection("bookings").addDocument(data: data)
        return ref.documentID
    }

    func fetchBookings(forUserId userId: String) async throws -> [DBBooking] {
        let snapshot = try await db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? DBBooking(id: doc.documentID, data: doc.data())
        }
    }

    func confirmCheckIn(bookingId: String) async throws {
        let docRef = db.collection("bookings").document(bookingId)
        let snapshot = try await docRef.getDocument()
        guard let data = snapshot.data(),
              let booking = try? DBBooking(id: bookingId, data: data) else {
            throw BookingError.notFound
        }

        guard booking.status == .active else { throw BookingError.notActive }
        guard booking.checkedInAt == nil else { throw BookingError.alreadyCheckedIn }
        guard Self.isCheckInDay(checkIn: booking.checkIn) else {
            throw BookingError.checkInNotToday
        }

        try await docRef.updateData([
            "status": BookingStatus.checkedIn.rawValue,
            "checkedInAt": FieldValue.serverTimestamp()
        ])
    }

    func processNoShowCancellations(forUserId userId: String) async throws {
        let snapshot = try await db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        let batch = db.batch()
        var hasUpdates = false

        for doc in snapshot.documents {
            guard let booking = try? DBBooking(id: doc.documentID, data: doc.data()) else { continue }
            guard Self.shouldAutoCancelForNoShow(booking: booking) else { continue }

            batch.updateData([
                "status": BookingStatus.cancelled.rawValue,
                "cancelReason": "no_show",
                "cancelledAt": FieldValue.serverTimestamp()
            ], forDocument: doc.reference)
            hasUpdates = true
        }

        if hasUpdates {
            try await batch.commit()
        }
    }

    func cancelBooking(bookingId: String) async throws {
        let docRef = db.collection("bookings").document(bookingId)
        let snapshot = try await docRef.getDocument()
        guard let data = snapshot.data() else {
            throw BookingError.notFound
        }

        let checkIn: Date
        if let ts = data["checkIn"] as? Timestamp {
            checkIn = ts.dateValue()
        } else if let d = data["checkIn"] as? Date {
            checkIn = d
        } else {
            throw BookingError.notFound
        }

        guard Self.canCancelBooking(checkIn: checkIn) else {
            throw BookingError.cancellationTooLate(daysRequired: Self.cancellationDeadlineDays)
        }

        try await docRef.updateData([
            "status": BookingStatus.cancelled.rawValue,
            "cancelReason": "user",
            "cancelledAt": FieldValue.serverTimestamp()
        ])
    }

    func hasActiveBookings(forHotelId hotelId: String) async throws -> Bool {
        let snapshot = try await db.collection("bookings")
            .whereField("hotelId", isEqualTo: hotelId)
            .getDocuments()

        let now = Date()
        return snapshot.documents.contains { doc in
            Self.isActiveBooking(data: doc.data(), referenceDate: now)
        }
    }

    static func isActiveBooking(data: [String: Any], referenceDate: Date = Date()) -> Bool {
        let status = data["status"] as? String ?? BookingStatus.active.rawValue
        guard status != BookingStatus.cancelled.rawValue else { return false }

        let checkOut: Date
        if let ts = data["checkOut"] as? Timestamp {
            checkOut = ts.dateValue()
        } else if let d = data["checkOut"] as? Date {
            checkOut = d
        } else {
            return true
        }
        return checkOut > referenceDate
    }
}
