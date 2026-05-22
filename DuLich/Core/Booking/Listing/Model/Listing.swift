//
//  Listing.swift
//  BookingApp
//
//  Created by Macbook Pro on 27/4/26.
//

import Foundation
import SwiftUI

struct Listing: Identifiable, Codable, Hashable {
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
    var imageUrls: [String]
    var description: String?
    let distance: Int
    
    var localizedTitle: LocalizedStringKey { LocalizedStringKey(title) }
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
        case .selfCheckIn: return String(localized: "checkin_big")
        case .superHost: return String(localized: "hotel_quality_big")
        }
    }
    
    var subtitle: String {
        switch self {
        case .selfCheckIn: return String(localized: "checkin_small")
        case .superHost: return String(localized:"hotel_quality_small")
        }
    }
    var id: Int { return self.rawValue}
}

enum ListingAmenities: Int, Codable, Identifiable, Hashable {
    case breakfast
    case wifi
    case airConditioning
    case parking
    case tivi
    case pool
    
    var title: LocalizedStringKey {
        switch self {
        case .pool: return "swimming_pool"
        case .airConditioning: return "air_conditioner"
        case .breakfast: return "break_fast"
        case .tivi: return "t_v"
        case .parking: return "park_ing"
        case .wifi: return "wi_fi"
        }
    }
    
    var ImageName: String {
        switch self {
        case .pool: return "figure.pool.swim.circle"
        case .airConditioning: return "air.conditioner.horizontal"
        case .breakfast: return "fork.knife.circle"
        case .tivi: return "tv"
        case .parking: return "parkingsign.circle.fill"
        case .wifi: return "wifi"
        }
    }
    var id: Int { return self.rawValue}

}

