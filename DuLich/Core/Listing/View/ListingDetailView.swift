import SwiftUI
import MapKit

struct ListingDetailView: View {
    @Environment(\.dismiss) var dismiss
    let listing: Listing
    @State private var selectedRoom: String? = nil
    @State private var showMap: MapCameraPosition
    
    init(listing: Listing){
        self.listing = listing
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.7602, longitude: -80.19),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        self._showMap = State(initialValue: .region(region))
    }
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                ListingImageCarousel(listing: listing)
                    .frame(height: 320)
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                        .background {
                            Circle()
                                .fill(.white)
                                .frame(width: 32, height: 32)
                        }
                        .padding(32)
                        .contentShape(Rectangle())
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title)
                    .font(.title)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                        Text("\(listing.rating)")
                        Text(" - ")
                        Text("28 reviews")
                            .underline()
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.yellow)
                    .font(.caption)
                    
                    Text("\(listing.city), \(listing.address)")
                }
                .font(.caption)
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Host info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Khách sạn thuộc sở hữu bởi \(listing.ownerName)")
                        .font(.headline)
                        .frame(width: 250, alignment: .leading)
                }
                .frame(width: 300, alignment: .leading)
                Spacer()
                Image(listing.ownerImangUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            .padding()
            
            Divider()
            //features
            VStack(alignment: .leading, spacing: 16) {
                ForEach(listing.features) {feature in
                    HStack(spacing: 12){
                        Image(systemName: feature.imageName)
                        
                        VStack(alignment: .leading){
                            Text(feature.title)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                            Text(feature.subtitle)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Room selection
            VStack(alignment: .leading, spacing: 16) {
                Text("Hãy chọn loại phòng bạn muốn")
                    .font(.headline)
                
                if let roomPrices = listing.pricePerNight {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(roomPrices.keys.sorted(), id: \.self) { room in
                                VStack {
                                    Image(systemName: "bed.double")
                                    Text(room)
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 132, height: 100)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedRoom == room ? Color.pink : Color.gray, lineWidth: 2)
                                }
                                .onTapGesture {
                                    selectedRoom = room
                                }
                            }
                        }
                    }
                    .scrollTargetBehavior(.paging)
                }
            }
            .padding()
            
            Divider()
            
            // Amenities
            VStack(alignment: .leading, spacing: 16) {
                Text("Các tiện ích được cung cấp")
                    .font(.headline)
                
                ForEach(listing.amenities, id: \.self) { amenity in
                    HStack {
                        Image(systemName: amenity.ImageName)
                        Text(amenity.title)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            .padding()
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Địa điểm")
                    .font(.headline)
                
                Map()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea()
        .padding(.bottom, 64)
        .overlay(alignment: .bottom) {
            VStack {
                Divider()
                    .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        if let selectedRoom = selectedRoom,
                           let price = listing.pricePerNight?[selectedRoom] {
                            Text("\(price) VNĐ")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Giá một đêm")
                                .font(.footnote)
                            Text("Đã chọn: \(selectedRoom)")
                                .font(.footnote)
                                .foregroundStyle(.pink)
                        } else {
                            Text("Chưa chọn phòng")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                    }
                    Spacer()
                    
                    Button {
                        print("Đặt phòng: \(selectedRoom ?? "Chưa chọn")")
                    } label: {
                        Text("Đặt phòng")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 140, height: 40)
                            .background(.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 32)
            }
            .background(.white)
        }
    }
}

#Preview {
    ListingDetailView(listing: DeveloperPreview.shared.listings[0])
}
