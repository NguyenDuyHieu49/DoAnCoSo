//
//  ExploreViewModel.swift
//  BookingApp
//
//  Created by Macbook Pro on 3/5/26.
//

import Foundation
import Combine

class ExploreViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    private let service: ExploreService
    
    init (service: ExploreService) {
        self.service = service
        
        Task { await fecthListing()}
    }
    func fecthListing() async {
        do {
            self.listings =  try await service.fecthListings()
        } catch {
            print("Error fetching listings: \(error.localizedDescription)")
        }
        
    }
    func updateListingLocation(_ location: String) {
            let filteredListings = listings.filter {
                $0.city.lowercased() == location.lowercased() ||
                $0.district.lowercased() == location.lowercased()
            }
        self.listings = filteredListings.isEmpty ? listings : filteredListings
        }
    }
