//
//  Listing.swift
//  BookingApp
//
//  Created by Macbook Pro on 27/4/26.
//

import Foundation

struct Listing: Identifiable, Codable, Hashable{
    let id: String
    let ownerUid: String
    let ownerName: String
    let ownerImangUrl: String
    var pricePerNight: [String: Int]?
    let latitude: Double
    let longitude: Double
    let address: String
    let city: String
    let title: String
    var rating: Double
    let district: String
    var features: [ListingFeatures]
    var amenities: [ListingAmenities]
    let type: ListingType
    var imageUrls: [String]
    let distance: Int

}

enum ListingFeatures: Int, Codable, Identifiable, Hashable {
    case selfCheckIn
    case superHost
    
    var imageName: String {
        switch self {
        case .selfCheckIn: return "door.left.hand.open"
        case .superHost: return "medal"
        }
    }
    
    var title: String {
        switch self {
        case .selfCheckIn: return "Check-in riêng tư"
        case .superHost: return "Khách sạn đạt chuẩn quốc tế"
        }
    }
    
    var subtitle: String {
        switch self {
        case .selfCheckIn: return "Check-in chỉ với 1 lần chạm"
        case .superHost: return "Với đội ngũ lễ tân, nhân viên chuyên nghiệp, được đào tạo bài bản"
        }
    }
    var id: Int { return self.rawValue}
}

enum ListingAmenities: Int, Codable, Identifiable, Hashable {
    case breakfast
    case wifi
    case airConditioning
    case parking
    case balcony
    case pool
    
    var title: String {
        switch self {
        case .pool: return "Swimming Pool"
        case .airConditioning: return "Air Conditioning"
        case .breakfast: return "Free Breakfast"
        case .balcony: return "Balcony"
        case .parking: return "Parking"
        case .wifi: return "Free Wi-Fi"
        }
    }
    
    var ImageName: String {
        switch self {
        case .pool: return "figure.pool.swim.circle"
        case .airConditioning: return "air.conditioner.horizontal"
        case .breakfast: return "fork.knife.circle"
        case .balcony: return "balcony"
        case .parking: return "parkingsign.circle.fill"
        case .wifi: return "wifi"
        }
    }
    var id: Int { return self.rawValue}

}

enum ListingType: Int, Codable, Identifiable, Hashable {
    case apartment
    case house
    case villa
    
    var title: String {
        switch self {
        case .apartment: return "Apartment"
        case .house: return "House"
        case .villa: return "Villa"
        }
    }
    var id: Int { return self.rawValue}
}
