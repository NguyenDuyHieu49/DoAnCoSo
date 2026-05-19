import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject private var authState: AuthState
    @State private var showSignInView = false

    var body: some View {
        let _ = print("[MainTabView] isAdmin:", authState.isAdmin, "userRole:", authState.userRole)
        TabView(selection: $selectedTab) {

            if authState.isAdmin {
                NavigationStack {
                    AdminDashboardView()          
                }
                .tabItem { Label("Quản lý", systemImage: "shield.checkered") }
                .tag(AppTab.explore)

                NavigationStack {
                    SettingsView(showSignInView: $showSignInView)
                }
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(AppTab.settings)

            } else {
                // ── USER TABS ───────────────────────────────
                NavigationStack { ExploreView() }
                .tabItem { Label("Explore", systemImage: "safari") }
                .tag(AppTab.explore)

                NavigationStack { HistoryView() }
                .tabItem { Label("History", systemImage: "clock") }
                .tag(AppTab.history)

                NavigationStack { ProfileView() }
                .tabItem { Label("Personal", systemImage: "person.crop.circle") }
                .tag(AppTab.profile)

                NavigationStack {
                    SettingsView(showSignInView: $showSignInView)
                }
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(AppTab.settings)
            }
        }
        // Khi role thay đổi → reset tab về đầu
        .onChange(of: authState.isAdmin) { _ in
            selectedTab = .explore
        }
    }
}
