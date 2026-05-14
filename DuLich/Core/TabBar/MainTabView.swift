// MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: AppTab
    @State private var showSignInView = false 
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ExploreView()
            }
            .tabItem { Label("Khám phá", systemImage: "safari") }
            .tag(AppTab.explore)

            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("Lịch sử", systemImage: "clock") }
            .tag(AppTab.history)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Cá nhân", systemImage: "person.crop.circle") }
            .tag(AppTab.profile)

            NavigationStack {
                SettingsView(showSignInView: $showSignInView)
            }
            .tabItem { Label("Cài đặt", systemImage: "gear") }
            .tag(AppTab.settings)
        }
    }
}

#Preview {
    MainTabView(selectedTab: .constant(.explore))
}
