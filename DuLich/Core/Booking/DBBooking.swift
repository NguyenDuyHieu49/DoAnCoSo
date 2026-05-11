// DBBooking.swift
import Foundation
import FirebaseFirestore

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
         createdAt: Date? = nil) {
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

        if let ts = data["checkIn"] as? Timestamp { self.checkIn = ts.dateValue() }
        else if let d = data["checkIn"] as? Date { self.checkIn = d }
        else { self.checkIn = Date() }

        if let ts = data["checkOut"] as? Timestamp { self.checkOut = ts.dateValue() }
        else if let d = data["checkOut"] as? Date { self.checkOut = d }
        else { self.checkOut = Calendar.current.date(byAdding: .day, value: 1, to: self.checkIn) ?? Date() }

        if let ts = data["createdAt"] as? Timestamp { self.createdAt = ts.dateValue() }
        else if let d = data["createdAt"] as? Date { self.createdAt = d }
        else { self.createdAt = nil }
    }
}
