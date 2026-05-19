// RootView.swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authState: AuthState
    @State private var showSignIn: Bool = false
    @State private var selectedTab: AppTab = .explore

    var body: some View {
        MainTabView(selectedTab: $selectedTab)
            .environmentObject(authState) 
            .task {
                print("RootView.task — authState.isSignedIn:", authState.isSignedIn)
                showSignIn = !authState.isSignedIn
                if authState.isSignedIn {
                    selectedTab = .explore
                }
            }
            .task {
                print("RootView.task — authState.isSignedIn:", authState.isSignedIn)
            }
            .onAppear {
                print("RootView.onAppear — authState.isSignedIn:", authState.isSignedIn)
            }

            .onChange(of: authState.isSignedIn) { signedIn in
                print("RootView.onChange isSignedIn ->", signedIn)
                if signedIn {
                    selectedTab = .explore
                    // Đóng màn sign-in nếu đang mở
                    showSignIn = false
                } else {
                    // Nếu user sign out, showSignIn = true để yêu cầu đăng nhập
                    showSignIn = true
                }
            }
            .fullScreenCover(isPresented: $showSignIn) {
                NavigationStack {
                    AuthenticationView(showSignInView: $showSignIn)
                        .interactiveDismissDisabled(true)
                        .environmentObject(authState) // đảm bảo AuthenticationView có access tới authState
                }
            }
    }
}
