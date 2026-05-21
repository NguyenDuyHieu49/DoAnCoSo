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

    var onSignInSuccess: (() -> Void)? = nil

    var body: some View {
        ZStack {
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

            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 280, height: 280)
                .blur(radius: 65)
                .offset(x: -110, y: -220)

            Circle()
                .fill(Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.28))
                .frame(width: 220, height: 220)
                .blur(radius: 55)
                .offset(x: 130, y: 200)

            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .offset(x: 60, y: -60)

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.22))
                                .frame(width: 88, height: 88)
                                .blur(radius: 2)

                            Image(systemName: "person.2.circle.fill")
                                .font(.system(size: 52, weight: .thin))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color.white.opacity(0.75)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .padding(.bottom, 4)

                        Text("Chào mừng")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.blue.opacity(0.25), radius: 4, x: 0, y: 2)

                        Text("Chọn phương thức đăng nhập")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 64)
                    .padding(.bottom, 44)

                    VStack(spacing: 14) {

                        Button(action: {
                            Task {
                                do {
                                    let result = try await viewModel.signInAnonymous()
                                    print("[AuthView] anonymous uid:", result.uid)
                                    Task { @MainActor in
                                        authState.startListening()
                                        onSignInSuccess?()
                                        showSignInView = false
                                    }
                                } catch {
                                    print("Anonymous sign-in error:", error.localizedDescription)
                                }
                            }
                        }) {
                            authButtonLabel(
                                title: "guest_button",
                                systemImage: "person.crop.circle",
                                style: .secondary
                            )
                        }

                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color.white.opacity(0.4))
                                .frame(height: 1)
                            Text("hoặc")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.65))
                                .fixedSize()
                            Rectangle()
                                .fill(Color.white.opacity(0.4))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 2)

                        NavigationLink {
                            SignInEmailView(showSignInView: $showSignInView)
                                .environmentObject(authState)
                        } label: {
                            authButtonLabel(
                                title: "email_button",
                                systemImage: "envelope.fill",
                                style: .primary
                            )
                        }

                        Button {
                            Task {
                                do {
                                    let resultModel = try await viewModel.signInGoogle()
                                    print("[AuthView] signInGoogle uid:", resultModel.uid)
                                    Task { @MainActor in
                                        authState.startListening()
                                        onSignInSuccess?()
                                        showSignInView = false
                                    }
                                } catch {
                                    print("Google sign-in error:", error.localizedDescription)
                                }
                            }
                        } label: {
                            authButtonLabel(
                                title: "google_button",
                                imageName: "google",
                                style: .google
                            )
                        }
                    }
                    .padding(24)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(.ultraThinMaterial)

                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.white.opacity(0.18))

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
                Text("Đăng nhập")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onReceive(authState.$isSignedIn) { signedIn in
            if signedIn {
                Task { @MainActor in
                    onSignInSuccess?()
                    showSignInView = false
                }
            }
        }
    }

    private enum ButtonStyle { case primary, secondary, google }

    @ViewBuilder
    private func authButtonLabel(
        title: LocalizedStringKey,
        systemImage: String? = nil,
        imageName: String? = nil,
        style: ButtonStyle
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(buttonBackground(for: style))
                .frame(height: 54)
                .shadow(color: buttonShadow(for: style), radius: 8, x: 0, y: 4)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(height: 54)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.45), lineWidth: 1)
                .frame(height: 54)
            HStack(spacing: 12) {
                Group {
                    if let system = systemImage {
                        Image(systemName: system)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(iconColor(for: style))
                    } else if let name = imageName {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                }
                .frame(width: 28)

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(labelColor(for: style))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(labelColor(for: style).opacity(0.5))
            }
            .padding(.horizontal, 18)
        }
    }

    private func buttonBackground(for style: ButtonStyle) -> AnyShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.45, blue: 0.95),
                        Color(red: 0.35, green: 0.6, blue: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .secondary:
            return AnyShapeStyle(Color.white.opacity(0.3))
        case .google:
            return AnyShapeStyle(Color.white.opacity(0.82))
        }
    }

    private func buttonShadow(for style: ButtonStyle) -> Color {
        switch style {
        case .primary:
            return Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.4)
        case .secondary:
            return Color.blue.opacity(0.1)
        case .google:
            return Color.black.opacity(0.08)
        }
    }

    private func labelColor(for style: ButtonStyle) -> Color {
        switch style {
        case .primary: return .white
        case .secondary: return .white
        case .google: return Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }

    private func iconColor(for style: ButtonStyle) -> Color {
        switch style {
        case .primary: return .white
        case .secondary: return .white.opacity(0.9)
        case .google: return Color(red: 0.15, green: 0.15, blue: 0.2)
        }
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
            .environmentObject(AuthState())
    }
}
