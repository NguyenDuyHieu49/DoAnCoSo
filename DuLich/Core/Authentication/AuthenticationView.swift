// AuthenticationView.swift
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Combine
import FirebaseAuth

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool

    @EnvironmentObject private var authState: AuthState

    // NEW: closure to notify parent that sign-in succeeded
    var onSignInSuccess: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    do {
                        let result = try await viewModel.signInAnonymous()
                        print("[AuthView] anonymous uid:", result.uid)
                        Task { @MainActor in
                            authState.startListening()
                            // Notify parent and close
                            onSignInSuccess?()
                            showSignInView = false
                        }
                    } catch {
                        print("Anonymous sign-in error:", error.localizedDescription)
                    }
                }
            }) {
                authButtonLabel(title: "Đăng nhập với tư cách khách", systemImage: "person.crop.circle")
            }

            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
                    .environmentObject(authState)
            } label: {
                authButtonLabel(title: "Đăng nhập với Email", systemImage: "envelope")
            }

            Button {
                Task {
                    do {
                        let resultModel = try await viewModel.signInGoogle()
                        print("[AuthView] signInGoogle uid:", resultModel.uid)
                        Task { @MainActor in
                            authState.startListening()
                            // Notify parent that onboarding can finish
                            onSignInSuccess?()
                            // Close this view/sheet
                            showSignInView = false
                        }
                    } catch {
                        print("Google sign-in error:", error.localizedDescription)
                    }
                }
            } label: {
                authButtonLabel(title: "Đăng nhập với Google", imageName: "google")
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Đăng nhập")
        .onReceive(authState.$isSignedIn) { signedIn in
            if signedIn {
                Task { @MainActor in
                    // In case authState changes from elsewhere, ensure parent is notified and view closed
                    onSignInSuccess?()
                    showSignInView = false
                }
            }
        }
    }

    @ViewBuilder
    private func authButtonLabel(title: String, systemImage: String? = nil, imageName: String? = nil) -> some View {
        HStack {
            if let system = systemImage {
                Image(systemName: system)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 8)
            } else if let name = imageName {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 8)
            }

            Spacer()
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
        .frame(height: 56)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
    }
}

// Preview
#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
            .environmentObject(AuthState())
    }
}
