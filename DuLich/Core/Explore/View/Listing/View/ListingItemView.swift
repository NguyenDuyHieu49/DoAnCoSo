// ListingItemView.swift
import SwiftUI
struct ListingItemView: View {
    let listing: Listing

    var body: some View {
        VStack(spacing: 6) {
            ListingImageCarousel(listing: listing)
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(listing.city), \(listing.address)")
                        .fontWeight(.semibold)
                        .foregroundColor(.teal)
                    Text("200 km away").foregroundStyle(.gray)
                    Text("Apr 12, 2026").foregroundStyle(.gray)
                    HStack(spacing: 4) {
                        Text("VND 100 millions").fontWeight(.semibold)
                        Text("night").foregroundColor(.black)
                    }
                    .foregroundColor(.teal)
                }
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                    Text("4.0")
                }
                .foregroundColor(.yellow)
            }
            .font(.footnote)
        }
        .padding()
        .contentShape(Rectangle()) // giữ vùng nhấn cho toàn bộ cell
    }
}
