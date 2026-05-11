// BookingManager.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

final class BookingManager {
    static let shared = BookingManager()
    private let db = Firestore.firestore()
    private init() {}

    /// Create a booking document in Firestore and return its document ID
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

        // merge meta
        meta.forEach { data[$0.key] = $0.value }

        let ref = try await db.collection("bookings").addDocument(data: data)
        return ref.documentID
    }

    /// Fetch bookings for a user
    func fetchBookings(forUserId userId: String) async throws -> [DBBooking] {
        let snapshot = try await db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? DBBooking(id: doc.documentID, data: doc.data())
        }
    }

    /// Optional: cancel/delete booking
    func cancelBooking(bookingId: String) async throws {
        try await db.collection("bookings").document(bookingId).delete()
    }
}
