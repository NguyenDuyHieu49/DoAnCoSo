//
//  ExploreService.swift
//  BookingApp
//
//  Created by Macbook Pro on 3/5/26.
//

import Foundation

class ExploreService{
    
    func fecthListings() async throws -> [Listing] {
        return DeveloperPreview.shared.listings
    }
}
