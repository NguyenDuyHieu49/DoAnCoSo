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
    private var allListings: [Listing] = []   // giữ dữ liệu gốc
    private let service: ExploreService
    
    init(service: ExploreService) {
        self.service = service
        Task { await fetchListing() }
    }
    
    func fetchListing() async {
        do {
            let fetched = try await service.fecthListings()
            DispatchQueue.main.async {
                self.allListings = fetched
                self.listings = fetched
            }
        } catch {
            print("Error fetching listings: \(error.localizedDescription)")
        }
    }
    
    func searchDestination(_ location: String) {
        let keyword = location.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !keyword.isEmpty else {
            // nếu ô tìm kiếm trống thì trả về toàn bộ danh sách
            listings = allListings
            return
        }
        
        let filteredListings = allListings.filter {
            $0.city.lowercased().contains(keyword) ||
            $0.district.lowercased().contains(keyword)
        }
        
        // nếu không có kết quả thì vẫn hiển thị toàn bộ
        listings = filteredListings.isEmpty ? allListings : filteredListings
    }
}
