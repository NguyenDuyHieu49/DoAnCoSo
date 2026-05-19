// ExploreService.swift
import Foundation
import FirebaseFirestore

class ExploreService {

    private let db = Firestore.firestore()

    func fecthListings() async throws -> [Listing] {
        // 1. Thử lấy từ Firestore trước
        let snapshot = try await db.collection("hotels")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        let firestoreListings = snapshot.documents.compactMap { doc -> Listing? in
            let data = doc.data()
            let id = doc.documentID

            guard let title = data["title"] as? String,
                  let city  = data["city"]  as? String else { return nil }

            // pricePerNight: [String: Any] → [String: Int]
            var pricePerNight: [String: Int] = [:]
            if let raw = data["pricePerNight"] as? [String: Any] {
                for (key, val) in raw {
                    if let i = val as? Int           { pricePerNight[key] = i }
                    else if let d = val as? Double   { pricePerNight[key] = Int(d) }
                    else if let s = val as? String   { pricePerNight[key] = Int(s) ?? 0 }
                }
            }

            // amenities — lưu dưới dạng [Int] rawValue
            let amenityInts = data["amenities"] as? [Int] ?? []
            let amenities = amenityInts.compactMap { ListingAmenities(rawValue: $0) }

            // imageUrls: ưu tiên Storage URLs, fallback asset names
            let imageUrls = data["imageUrls"] as? [String] ?? []

            return Listing(
                id:             id,
                ownerUid:       data["ownerUid"]   as? String ?? "",
                ownerName:      data["ownerName"]  as? String ?? "",
                ownerImangUrl:  imageUrls.first    ?? "",
                pricePerNight:  pricePerNight,
                latitude:       data["latitude"]   as? Double ?? 0,
                longitude:      data["longitude"]  as? Double ?? 0,
                address:        data["address"]    as? String ?? "",
                city:           city,
                title:          title,
                rating:         data["rating"]     as? Double ?? 4.5,
                district:       data["district"]   as? String ?? "",
                features:       [],                               // mở rộng sau nếu cần
                amenities:      amenities,
                type:           .villa,
                imageUrls:      imageUrls.isEmpty ? ["placeholder"] : imageUrls,
                distance:       data["distance"] as? Int
                                ?? (data["distance"] as? Double).map { Int($0) }
                                ?? 0
            )
        }

        // 2. Nếu Firestore có data → trả về, ngược lại fallback DeveloperPreview
        if !firestoreListings.isEmpty {
            return firestoreListings
        }

        print("[ExploreService] Firestore trống, dùng DeveloperPreview")
        return DeveloperPreview.shared.listings
    }
}
