// ExploreService.swift
import Foundation
import FirebaseFirestore

class ExploreService {

    private let db = Firestore.firestore()

    func fetchListings() async throws -> [Listing] {
        let snapshot = try await db.collection("hotels")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        let firestoreListings = snapshot.documents.compactMap { doc -> Listing? in
            let data = doc.data()
            let id = doc.documentID

            guard let title = data["title"] as? String,
                  let city  = data["city"]  as? String else { return nil }

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

            let imageUrls = data["imageUrls"] as? [String] ?? []
            let images: [String] = imageUrls.isEmpty ? ["placeholder"] : imageUrls

            // Tách nhỏ các giá trị để giảm tải cho type-checker
            let ownerUid: String = data["ownerUid"] as? String ?? ""
            let ownerName: String = data["ownerName"] as? String ?? ""
            let ownerImangUrl: String = imageUrls.first ?? ""
            let latitude: Double = data["latitude"] as? Double ?? 0
            let longitude: Double = data["longitude"] as? Double ?? 0
            let address: String = data["address"] as? String ?? ""
            let rating: Double = data["rating"] as? Double ?? 4.5
            let district: String = data["district"] as? String ?? ""

            let rawDistanceInt = data["distance"] as? Int
            let rawDistanceDouble = data["distance"] as? Double
            let distance: Int = {
                if let i = rawDistanceInt { return i }
                if let d = rawDistanceDouble { return Int(d) }
                return 0
            }()

            return Listing(
                id:             id,
                ownerUid:       ownerUid,
                ownerName:      ownerName,
                ownerImangUrl:  ownerImangUrl,
                pricePerNight:  pricePerNight,
                latitude:       latitude,
                longitude:      longitude,
                address:        address,
                city:           city,
                title:          title,
                rating:         rating,
                district:       district,
                features:       [.selfCheckIn,.superHost],
                amenities:      amenities,
                imageUrls:      images,
                distance:       distance
            )
        }

        if !firestoreListings.isEmpty {
            return firestoreListings
        }

        print("[ExploreService] Firestore trống, dùng DeveloperPreview")
        return DeveloperPreview.shared.listings
    }
}
