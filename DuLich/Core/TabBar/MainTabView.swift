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
            .tabItem { Label("Explore", systemImage: "safari") }
            .tag(AppTab.explore)

            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("History", systemImage: "clock") }
            .tag(AppTab.history)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            .tag(AppTab.profile)

            NavigationStack {
                SettingsView(showSignInView: $showSignInView)
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(AppTab.settings)
        }
    }
}

