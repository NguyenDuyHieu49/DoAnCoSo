//
//  MainTabView.swift
//  BookingApp
//
//  Created by Macbook Pro on 27/4/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Khám phá", systemImage: "magnifyingglass") }

            WishlistsView()
                .tabItem { Label("Danh sách", systemImage: "heart") }

            CreateAccountView()
                .tabItem { Label("Thông tin", systemImage: "person.fill") }
        }
    }
}

#Preview {
    MainTabView()
}
