//
//  ListingView.swift
//  BookingApp
//
//  Created by Macbook Pro on 12/4/26.
//

import SwiftUI

struct ListingItemView: View {
    
    let listing: Listing
    
    var body: some View {
        VStack(spacing: 6){
            // image
            
            ListingImageCarousel(listing: listing)
                .frame( height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        
            //listing details
            HStack(alignment: .top){
                // details
                VStack(alignment: .leading){
                    Text("\(listing.city), \(listing.address)")
                        .fontWeight(.semibold)
                        .foregroundColor(.teal)
                    
                    Text("200 km away")
                        .foregroundStyle(.gray)
                    
                    Text("Apr 12, 2026")
                        .foregroundStyle(.gray)
                    
                    
                    HStack(spacing: 4){
                        Text("VND 100 millions")
                            .fontWeight(.semibold)
                        Text("night")
                            .foregroundColor(.black)

                    }
                    .foregroundColor(.teal)

                }
                
                Spacer()
                
                //rating
                
                HStack(spacing: 2){
                    Image(systemName: "star.fill")
                    
                    Text("4.0")
                }
                .foregroundColor(.yellow)

            }
            .font(.footnote)
        }
        .padding()
    }
        
}

#Preview {
    ListingItemView(listing: DeveloperPreview.shared.listings[0])
}
