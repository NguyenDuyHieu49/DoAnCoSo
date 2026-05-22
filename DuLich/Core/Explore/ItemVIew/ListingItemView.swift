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
                    Text("\(listing.title)")
                        .fontWeight(.regular)
                        .font(.subheadline)
                        .foregroundColor(.teal)
                    Text("\(listing.address), \(listing.city)")
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                        .minimumScaleFactor(0.5)
                }
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                    Text("\(listing.rating, specifier: "%.1f") stars")
                        .font(.footnote)
                }
                .foregroundColor(.yellow)
            }
        }
        .padding()
        .contentShape(Rectangle())
    }
}
