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
        TabView{
            ForEach(listing.imageUrls, id: \.self) { image in
                Image(image)
                    .resizable()
                    .scaledToFill()
            }
        }
            .tabViewStyle(.page)
    }
}

#Preview {
    ListingImageCarousel(listing: DeveloperPreview.shared.listings[0])
}

