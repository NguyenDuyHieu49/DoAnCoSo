//
//  ExploreViewModel.swift
//  BookingApp
//
//  Created by Macbook Pro on 3/5/26.
//

// ExploreViewModel.swift
import Foundation
import Combine

class ExploreViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading: Bool = false

    private var allListings: [Listing] = []
    private let service: ExploreService

    init(service: ExploreService) {
        self.service = service
        Task { await fetchListing() }
    }

    // MARK: - Fetch (gọi lần đầu từ init)
    func fetchListing() async {
        await MainActor.run { isLoading = true }
        do {
            let fetched = try await service.fecthListings()
            await MainActor.run {
                self.allListings = fetched
                self.listings    = fetched
                self.isLoading   = false
            }
        } catch {
            await MainActor.run { self.isLoading = false }
            print("[ExploreViewModel] fetchListing error:", error.localizedDescription)
        }
    }

    // MARK: - loadListings (gọi sau khi Admin thêm / xoá khách sạn)
    func loadListings() async {
        await fetchListing()
    }

    // MARK: - Search
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

        listings = filtered.isEmpty ? allListings : filtered
    }
}
