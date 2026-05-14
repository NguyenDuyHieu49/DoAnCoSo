// SignInEmailView.swift
import SwiftUI
import Combine

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.75, blue: 1.0),
                    Color(red: 0.75, green: 0.88, blue: 1.0),
                    Color(red: 0.88, green: 0.93, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative blurred orbs
            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: -100, y: -200)

            Circle()
                .fill(Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: 120, y: 180)

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 56, weight: .thin))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
                            .padding(.bottom, 4)

                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.blue.opacity(0.25), radius: 4, x: 0, y: 2)

                        Text("Sign in to continue")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)

                    // Glass card
                    VStack(spacing: 18) {
                        // Email field
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Email", systemImage: "envelope")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.75))
                                .textCase(.uppercase)
                                .tracking(0.8)

                            TextField("your@email.com", text: Binding(
                                get: { viewModel.email },
                                set: { viewModel.email = $0 }
                            ))
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .tint(Color(red: 0.2, green: 0.45, blue: 0.95))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.white.opacity(0.85))
                                    .shadow(color: Color.blue.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Password", systemImage: "lock")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.75))
                                .textCase(.uppercase)
                                .tracking(0.8)

                            SecureField("••••••••", text: Binding(
                                get: { viewModel.password },
                                set: { viewModel.password = $0 }
                            ))
                            .textContentType(.password)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .tint(Color(red: 0.2, green: 0.45, blue: 0.95))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.white.opacity(0.85))
                                    .shadow(color: Color.blue.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                        }

                        // Sign In Button
                        Button(action: {
                            Task {
                                isLoading = true
                                do {
                                    try await viewModel.signup()
                                    showSignInView = false
                                    isLoading = false
                                    return
                                } catch {
                                    print("signup error:", error)
                                }
                                do {
                                    try await viewModel.signin()
                                    showSignInView = false
                                    isLoading = false
                                    return
                                } catch {
                                    print("signin error:", error)
                                    isLoading = false
                                }
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.2, green: 0.45, blue: 0.95),
                                                Color(red: 0.35, green: 0.6, blue: 1.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 54)
                                    .shadow(color: Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.45), radius: 12, x: 0, y: 6)

                                // Glass sheen overlay
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.25), Color.white.opacity(0.0)],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                                    .frame(height: 54)

                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    HStack(spacing: 8) {
                                        Text("Sign In")
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                }
                            }
                        }
                        .disabled(isLoading)
                        .padding(.top, 4)
                    }
                    .padding(24)
                    .background(
                        // Glassmorphism card
                        ZStack {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(.ultraThinMaterial)

                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.white.opacity(0.18))

                            // Top highlight border
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.7),
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                    )
                    .shadow(color: Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.18), radius: 30, x: 0, y: 16)
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sign In With Email")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
    }
}
