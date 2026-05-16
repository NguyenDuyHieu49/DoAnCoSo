import SwiftUI

struct ListingItemView: View {
    let listing: Listing

    var body: some View {
        VStack(spacing: 6) {
            NavigationLink {
                ListingDetailView(listing: listing)
            } label: {
                ListingImageCarousel(listing: listing)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(listing.address), \(listing.city)")
                        .fontWeight(.semibold)
                        .foregroundColor(.teal)
                    Text("\(listing.distance) km").foregroundStyle(.gray)
                }
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                    Text("\(listing.rating, specifier: "%.1f") stars")
                }
                .foregroundColor(.yellow)
            }
            .font(.footnote)
        }
        .padding()
        .contentShape(Rectangle())
    }
}
