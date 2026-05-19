//
//  ListingImageCarousel.swift
//  BookingApp
//
//  Created by Macbook Pro on 12/4/26.
//

import SwiftUI

struct ListingImageCarousel: View {
    let listing: Listing

    var body: some View {
        TabView {
            ForEach(listing.imageUrls, id: \.self) { imageUrl in
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(white: 0.9))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Rectangle()
                            .fill(Color(white: 0.85))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(white: 0.6))
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    ListingImageCarousel(listing: DeveloperPreview.shared.listings[0])
}
