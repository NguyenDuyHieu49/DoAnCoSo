// AdminHotelManager.swift
import Foundation
import FirebaseFirestore
import UIKit

final class AdminHotelManager {

    static let shared = AdminHotelManager()
    private init() {}

    private let db = Firestore.firestore()

    @discardableResult
    func addHotel(form: HotelForm, images: [UIImage]) async throws -> String {
        let docRef = db.collection("hotels").document()
        let hotelId = docRef.documentID

        let imageUrls = try await CloudinaryService.uploadImages(images)

        var data = form.toFirestoreDict()
        data["id"]        = hotelId
        data["imageUrls"] = imageUrls
        data["createdAt"] = FieldValue.serverTimestamp()

        try await docRef.setData(data)
        try await createRooms(for: form.priceEntries, hotelId: hotelId)
        print("[AdminHotelManager] addHotel success, id:", hotelId)
        return hotelId
    }

    private func createRooms(for entries: [PriceEntry], hotelId: String) async throws {
        let batch = db.batch()
        for entry in entries where !entry.roomType.isEmpty {
            let quantity = Int(entry.quantity) ?? 1
            let price = Int(entry.price) ?? 0
            for i in 1...max(1, quantity) {
                let roomRef = db.collection("rooms").document()
                let roomNumber = "\(entry.roomType.prefix(3).uppercased())\(String(format: "%02d", i))"
                batch.setData([
                    "hotelId":    hotelId,
                    "roomType":   entry.roomType,
                    "roomNumber": roomNumber,
                    "price":      price
                ], forDocument: roomRef)
            }
        }
        try await batch.commit()
        print("[AdminHotelManager] createRooms success for hotelId:", hotelId)
    }
    enum HotelDeletionError: LocalizedError {
        case hasActiveBookings

        var errorDescription: String? {
            String(localized: "hotel_delete_blocked")
        }
    }

    func deleteHotel(id: String) async throws {
        let hasBookings = try await BookingManager.shared.hasActiveBookings(forHotelId: id)
        guard !hasBookings else {
            throw HotelDeletionError.hasActiveBookings
        }

        let roomsSnapshot = try await db.collection("rooms")
            .whereField("hotelId", isEqualTo: id)
            .getDocuments()
        let batch = db.batch()
        for doc in roomsSnapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        batch.deleteDocument(db.collection("hotels").document(id))
        try await batch.commit()
        print("[AdminHotelManager] deleteHotel success, id:", id)
    }

    func fetchHotels() async throws -> [HotelForm] {
        let snapshot = try await db.collection("hotels")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? HotelForm(id: doc.documentID, data: doc.data())
        }
    }
}
struct HotelForm: Identifiable {
    var id: String = UUID().uuidString

    var title: String = ""
    var ownerName: String = ""
    var address: String = ""
    var city: String = ""
    var district: String = ""
    var description: String = ""

    var latitude: String = ""
    var longitude: String = ""

   
    var priceEntries: [PriceEntry] = [PriceEntry()]

    var amenities: [ListingAmenities] = []

    var rating: String = "4.5"

    var selectedImages: [UIImage] = []
    
    var distance: Int = 0

    func toFirestoreDict() -> [String: Any] {
        var dict: [String: Any] = [
            "title":       title,
            "ownerName":   ownerName,
            "address":     address,
            "city":        city,
            "district":    district,
            "description": description,
            "latitude":    Double(latitude) ?? 0.0,
            "longitude":   Double(longitude) ?? 0.0,
            "rating":      Double(rating) ?? 4.5,
            "amenities":   amenities.map { $0.rawValue },
            "distance":    distance
        ]
        var priceDict: [String: Int] = [:]
        for entry in priceEntries where !entry.roomType.isEmpty {
            priceDict[entry.roomType] = Int(entry.price) ?? 0
        }
        dict["pricePerNight"] = priceDict
        return dict
    }

    // Init từ Firestore document
    init(id: String, data: [String: Any]) throws {
        self.id          = id
        self.title       = data["title"]       as? String ?? ""
        self.ownerName   = data["ownerName"]   as? String ?? ""
        self.address     = data["address"]     as? String ?? ""
        self.city        = data["city"]        as? String ?? ""
        self.district    = data["district"]    as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.latitude    = String(data["latitude"]  as? Double ?? 0)
        self.longitude   = String(data["longitude"] as? Double ?? 0)
        self.rating      = String(data["rating"]    as? Double ?? 4.5)
        if let priceDict = data["pricePerNight"] as? [String: Any] {
            self.priceEntries = priceDict.compactMap { key, val -> PriceEntry? in
                let intVal: Int
                if let i = val as? Int            { intVal = i }
                else if let d = val as? Double    { intVal = Int(d) }
                else if let s = val as? String,
                        let i = Int(s)            { intVal = i }
                else                              { return nil }
                return PriceEntry(roomType: key, price: String(intVal))
            }
        }
        if let amenityInts = data["amenities"] as? [Int] {
            self.amenities = amenityInts.compactMap { ListingAmenities(rawValue: $0) }
        }
        if let d = data["distance"] as? Int {
            self.distance = d
        } else if let d = data["distance"] as? Double {
            self.distance = Int(d)
        } else if let s = data["distance"] as? String, let d = Int(s) {
            self.distance = d
        } else {
            self.distance = 0
        }
    }

    init() {}
}

struct PriceEntry: Identifiable {
    var id = UUID()
    var roomType: String = ""
    var price: String = ""
    var quantity: String = ""
}
