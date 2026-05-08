import SwiftUI

struct ExploreView: View {
    @State private var showDestinationSearch = false
    @StateObject var viewModel = ExploreViewModel(service: ExploreService())
    @StateObject var weatherVM = WeatherViewModel()
    @State private var showWeatherDetail = false
    
    var body: some View {
        NavigationStack {
            if showDestinationSearch {
                DestinationSearch(show: $showDestinationSearch) { query in
                    viewModel.searchDestination(query)
                }
            } else {
                ScrollView {
                    SearchBar()
                        .onTapGesture {
                            withAnimation(.snappy) {
                                showDestinationSearch.toggle()
                            }
                        }
                    
                    WeatherCard(viewModel: weatherVM)
                        .onAppear {
                            Task { await weatherVM.fetchWeather(for: "Hanoi") }
                        }
                        .onTapGesture {
                            showWeatherDetail = true
                        }
                        .sheet(isPresented: $showWeatherDetail) {
                            WeatherDetailView(viewModel: weatherVM)
                        }
                    
                    LazyVStack(spacing: 32) {
                        ForEach(viewModel.listings) { listing in
                            NavigationLink(value: listing) {
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
