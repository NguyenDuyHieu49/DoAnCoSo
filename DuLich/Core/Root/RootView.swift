// RootView.swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authState: AuthState
    @State private var showSignIn: Bool = false
    @State private var selectedTab: AppTab = .explore

    var body: some View {
        MainTabView(selectedTab: $selectedTab)
            .onAppear {
                // Khi app mở, show SignIn nếu chưa đăng nhập
                showSignIn = !authState.isSignedIn
                if authState.isSignedIn {
                    selectedTab = .explore
                } else {
                    selectedTab = .explore
                }
            }
            // Lắng nghe publisher của AuthState
            .onReceive(authState.$isSignedIn) { signedIn in
                if signedIn {
                    selectedTab = .explore   // hoặc .profile nếu bạn muốn
                    showSignIn = false
                } else {
                    showSignIn = true
                }
            }
            .fullScreenCover(isPresented: $showSignIn, onDismiss: {
                if !authState.isSignedIn { showSignIn = true }
            }) {
                NavigationStack {
                    SignInEmailView(showSignInView: $showSignIn)
                        .interactiveDismissDisabled(true)
                }
            }
    }
}
