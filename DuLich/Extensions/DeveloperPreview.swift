import Foundation
final class DeveloperPreview {
    static let shared = DeveloperPreview()
    
    let listings: [Listing] = [
        .init(
            id: UUID().uuidString,
            ownerUid: UUID().uuidString,
            ownerName: "Ms. Lê Thu Thuỷ",
            ownerImangUrl: "samson1",
            pricePerNight: [
                "Phòng Chủ tịch": 50000000,
                "Phòng sang trọng": 30000000,
                "Phòng VIP": 10000000,
                "Phòng thường": 5000000
            ],
            latitude: 37.7749,
            longitude: -122.4194,
            address: "Sam Son",
            city: "Thanh Hoa",
            title: "Hercury Hotel",
            rating: 4.8,
            district: "CA",
            features: [.superHost, .selfCheckIn],
            amenities: [.breakfast,.airConditioning,.wifi,.pool,.parking],
            type: .villa,
            imageUrls: ["samson1","samson2","samson3","samson4"],
            distance: 200
        ),
        .init(
            id: UUID().uuidString,
            ownerUid: UUID().uuidString,
            ownerName: "Ms. Diệu Hương",
            ownerImangUrl: "dalat1",
            pricePerNight: [
                "Phòng Chủ tịch": 20000000,
                "Phòng sang trọng": 10000000,
                "Phòng VIP": 1500000,
                "Phòng thường": 900000
            ],
            latitude: 37.7749,
            longitude: -122.4194,
            address: "Da Lat",
            city: "Lam Dong",
            title: "New Century",
            rating: 4.8,
            district: "CA",
            features: [.superHost, .selfCheckIn],
            amenities: [.breakfast,.airConditioning,.wifi,.pool,.parking],
            type: .villa,
            imageUrls: ["dalat1","dalat2","dalat3","dalat4"],
            distance: 1408
        ),
        .init(
            id: UUID().uuidString,
            ownerUid: UUID().uuidString,
            ownerName: "Mr. Ai Do",
            ownerImangUrl: "phuquoc1",
            pricePerNight: [
                "Phòng Chủ tịch": 50000000,
                "Phòng sang trọng": 30000000,
                "Phòng VIP": 22000000,
                "Phòng thường": 10000000
            ],
            latitude: 37.7749,
            longitude: -122.4194,
            address: "Phu Quoc",
            city: "Kien Giang",
            title: "Seashells Phu Quoc Hotel & Spa",
            rating: 4.8,
            district: "CA",
            features: [.superHost, .selfCheckIn],
            amenities: [.breakfast,.airConditioning,.wifi,.pool,.parking],
            type: .villa,
            imageUrls: ["phuquoc1","phuquoc2","phuquoc3","phuquoc4"],
            distance: 2017
        ),
        .init(
            id: UUID().uuidString,
            ownerUid: UUID().uuidString,
            ownerName: "Mr. Đình Huy",
            ownerImangUrl: "male-profile-photo",
            pricePerNight: [
                "Phòng Chủ tịch": 50000000,
                "Phòng sang trọng": 30000000,
                "Phòng VIP": 22000000,
                "Phòng thường": 10000000
            ],
            latitude: 37.7749,
            longitude: -122.4194,
            address: "Nha Trang",
            city: "Khanh Hoa",
            title: "Liberty Central Nha Trang",
            rating: 4.8,
            district: "CA",
            features: [.superHost, .selfCheckIn],
            amenities: [.breakfast,.airConditioning,.wifi,.pool,.parking],
            type: .villa,
            imageUrls: ["nhatrang1","nhatrang2","nhatrang3","nhatrang4"],
            distance:  1280
        ),
        .init(
            id: UUID().uuidString,
            ownerUid: UUID().uuidString,
            ownerName: "Mr. Sashimi Hihihi",
            ownerImangUrl: "female-profile-photo",
            pricePerNight: [
                "Phòng Chủ tịch": 50000000,
                "Phòng sang trọng": 30000000,
                "Phòng VIP": 22000000,
                "Phòng thường": 10000000
            ],
            latitude: 37.7749,
            longitude: -122.4194,
            address: "Da Nang",
            city: "Da Nang",
            title: "HAIAN Beach Hotel & Spa",
            rating: 4.8,
            district: "CA",
            features: [.superHost, .selfCheckIn],
            amenities: [.breakfast,.airConditioning,.wifi,.pool,.parking],
            type: .villa,
            imageUrls: ["DaNang1","DaNang2","DaNang3","DaNang4"],
            distance:  1280
        )

    ]
}
