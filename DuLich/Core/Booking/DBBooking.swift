// DBBooking.swift
import Foundation
import FirebaseFirestore

enum BookingStatus: String, Hashable {
    case active
    case checkedIn = "checked_in"
    case cancelled

    var displayName: String {
        switch self {
        case .active: return String(localized: "booking_status_active")
        case .checkedIn: return String(localized: "booking_status_checked_in")
        case .cancelled: return String(localized: "booking_status_cancelled")
        }
    }
}

struct DBBooking: Identifiable, Hashable {
    let id: String
    let userId: String
    let hotelId: String
    let hotelName: String
    let hotelAddress: String?
    let roomType: String
    let price: Double
    let currency: String
    let checkIn: Date
    let checkOut: Date
    let createdAt: Date?
    let roomNumber: Int?
    let status: BookingStatus
    let checkedInAt: Date?
    let cancelReason: String?

    var isCancelled: Bool { status == .cancelled }
    var isCheckedIn: Bool { status == .checkedIn }

    init(id: String,
         userId: String,
         hotelId: String,
         hotelName: String,
         hotelAddress: String? = nil,
         roomType: String,
         price: Double,
         currency: String = "VND",
         checkIn: Date,
         checkOut: Date,
         createdAt: Date? = nil,
         roomNumber: Int? = nil,
         status: BookingStatus = .active,
         checkedInAt: Date? = nil,
         cancelReason: String? = nil) {
        self.id = id
        self.userId = userId
        self.hotelId = hotelId
        self.hotelName = hotelName
        self.hotelAddress = hotelAddress
        self.roomType = roomType
        self.price = price
        self.currency = currency
        self.checkIn = checkIn
        self.checkOut = checkOut
        self.createdAt = createdAt
        self.roomNumber = roomNumber
        self.status = status
        self.checkedInAt = checkedInAt
        self.cancelReason = cancelReason
    }

    init(id: String, data: [String: Any]) throws {
        self.id = id
        self.userId = data["userId"] as? String ?? ""
        self.hotelId = data["hotelId"] as? String ?? ""
        self.hotelName = data["hotelName"] as? String ?? ""
        self.hotelAddress = data["hotelAddress"] as? String
        self.roomType = data["roomType"] as? String ?? "Unknown"
        self.price = (data["price"] as? Double) ?? (data["price"] as? NSNumber)?.doubleValue ?? 0
        self.currency = data["currency"] as? String ?? "VND"

        if let num = data["roomNumber"] as? Int {
            self.roomNumber = num
        } else if let str = data["roomNumber"] as? String, let num = Int(str) {
            self.roomNumber = num
        } else {
            self.roomNumber = nil
        }

        if let rawStatus = data["status"] as? String,
           let parsed = BookingStatus(rawValue: rawStatus) {
            self.status = parsed
        } else {
            self.status = .active
        }
        self.cancelReason = data["cancelReason"] as? String

        if let ts = data["checkIn"] as? Timestamp { self.checkIn = ts.dateValue() }
        else if let d = data["checkIn"] as? Date { self.checkIn = d }
        else { self.checkIn = Date() }

        if let ts = data["checkOut"] as? Timestamp { self.checkOut = ts.dateValue() }
        else if let d = data["checkOut"] as? Date { self.checkOut = d }
        else { self.checkOut = Calendar.current.date(byAdding: .day, value: 1, to: self.checkIn) ?? Date() }

        if let ts = data["createdAt"] as? Timestamp { self.createdAt = ts.dateValue() }
        else if let d = data["createdAt"] as? Date { self.createdAt = d }
        else { self.createdAt = nil }

        if let ts = data["checkedInAt"] as? Timestamp { self.checkedInAt = ts.dateValue() }
        else if let d = data["checkedInAt"] as? Date { self.checkedInAt = d }
        else { self.checkedInAt = nil }
    }
}
