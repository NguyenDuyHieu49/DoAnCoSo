//
//  MainTabView.swift
//  BookingApp
//
//  Created by Macbook Pro on 27/4/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var showSignInView: Bool = false
    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Khám phá", systemImage: "magnifyingglass") }

            WishlistsView()
                .tabItem { Label("Danh sách", systemImage: "heart") }

            ProfileView(showSignInView: $showSignInView)
                .tabItem { Label("Thông tin", systemImage: "person.fill") }
        }
    }
}


#Preview {
    MainTabView()
}

