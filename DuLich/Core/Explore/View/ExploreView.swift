//
//  ExploreView.swift
//  BookingApp
//
//  Created by Macbook Pro on 12/4/26.
//

import SwiftUI
struct ExploreView: View {
    @State private var showDestinationSearch = false
    @StateObject var viewModel = ExploreViewModel(service:  ExploreService())
    
    var body: some View {
        NavigationStack {
            if showDestinationSearch {
                DestinationSearch(show: $showDestinationSearch)
            } else {
                ScrollView {
                    SearchBar()
                        .onTapGesture {
                            withAnimation(.snappy) {
                                showDestinationSearch.toggle()
                            }
                        }
                    LazyVStack(spacing: 32) {
                        ForEach(viewModel.listings) { listing in
                            NavigationLink(value: listing){
                                ListingItemView(listing: listing)
                                    .frame(height: 400)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding()
                }
                .navigationDestination(for: Listing.self) { listing in
                    ListingDetailView(listing: listing)
                        .navigationBarBackButtonHidden()
                }
            }
        }
    }
}

#Preview {
    ExploreView()
}

