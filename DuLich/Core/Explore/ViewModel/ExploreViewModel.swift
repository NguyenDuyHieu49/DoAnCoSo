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
    @Published var isLoading: Bool = false
    
    private var allListings: [Listing] = []
    private let service: ExploreService
    
    init(service: ExploreService) {
        self.service = service
        Task { await loadListings() }
    }

    func loadListings() async {
        await MainActor.run { isLoading = true }

        defer {
            Task { @MainActor in
                isLoading = false
            }
        }

        do {
            let data = try await service.fetchListings()

            await MainActor.run {
                allListings = data
                listings = data
            }

        } catch {
            print("[ExploreViewModel] loadListings error:", error.localizedDescription)
        }
    }
    
    func searchDestination(_ location: String) {
        
        let keyword = location
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !keyword.isEmpty else {
            listings = allListings
            return
        }
        
        let filtered = allListings.filter {
            
            $0.city.lowercased().contains(keyword) ||
            $0.district.lowercased().contains(keyword) ||
            $0.title.lowercased().contains(keyword) ||
            $0.address.lowercased().contains(keyword)
        }
        
        listings = filtered
    }
}

