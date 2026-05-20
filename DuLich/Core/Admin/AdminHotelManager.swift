// AdminHotelManager.swift
import Foundation
import FirebaseFirestore
import UIKit

final class AdminHotelManager {

    static let shared = AdminHotelManager()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Add hotel
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
        print("[AdminHotelManager] addHotel success, id:", hotelId)
        return hotelId
    }

    // MARK: - Delete hotel
    func deleteHotel(id: String) async throws {
        try await db.collection("hotels").document(id).delete()
        // ✅ Không cần xoá Storage nữa vì ảnh ở Cloudinary
        print("[AdminHotelManager] deleteHotel success, id:", id)
    }

    // MARK: - Fetch all hotels
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

    // MARK: Firestore serialization
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
            "amenities":   amenities.map { $0.rawValue }
        ]
        // pricePerNight dict
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
        // amenities lưu dưới dạng [Int] (rawValue của ListingAmenities)
        if let amenityInts = data["amenities"] as? [Int] {
            self.amenities = amenityInts.compactMap { ListingAmenities(rawValue: $0) }
        }
    }

    // Default init
    init() {}
}

// MARK: - PriceEntry  (loại phòng + giá)
struct PriceEntry: Identifiable {
    var id = UUID()
    var roomType: String = ""
    var price: String = ""
}
