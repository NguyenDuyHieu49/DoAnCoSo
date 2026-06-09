// SettingsView.swift
import SwiftUI
import Combine

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool

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
                .fill(Color.white.opacity(0.32))
                .frame(width: 270, height: 270)
                .blur(radius: 62)
                .offset(x: -110, y: -200)

            Circle()
                .fill(Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.25))
                .frame(width: 210, height: 210)
                .blur(radius: 52)
                .offset(x: 130, y: 230)

            ScrollView{
                VStack(spacing: 20) {

                    glassSection {
                        VStack(spacing: 0) {
                            sectionHeader(title: "account", icon: "person.circle.fill")

                            settingsButton(
                                title: "sign_out",
                                icon: "arrow.right.circle",
                                iconColor: Color(red: 0.2, green: 0.45, blue: 0.95),
                                showDivider: true
                            ) {
                                Task {
                                    do {
                                        try viewModel.signOut()
                                        showSignInView = true
                                    } catch {
                                        print(error)
                                    }
                                }
                            }

                            settingsButton(
                                title: "delete_account",
                                icon: "trash.circle",
                                iconColor: Color(red: 0.85, green: 0.15, blue: 0.15),
                                labelColor: Color(red: 0.85, green: 0.15, blue: 0.15),
                                showDivider: false
                            ) {
                                Task {
                                    do {
                                        try await viewModel.deleteAccount()
                                        showSignInView = true
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
                    }

                    if viewModel.authProviders.contains(.email) {
                        glassSection {
                            VStack(spacing: 0) {
                                sectionHeader(title: "Email", icon: "envelope.circle.fill")

                                settingsButton(
                                    title: "reset_password",
                                    icon: "key.horizontal",
                                    iconColor: Color(red: 0.2, green: 0.45, blue: 0.95),
                                    showDivider: true
                                ) {
                                    Task {
                                        do {
                                            try await viewModel.resetPassword()
                                            print("password_reset")
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }

                                settingsButton(
                                    title: "update_password",
                                    icon: "lock.rotation",
                                    iconColor: Color(red: 0.2, green: 0.45, blue: 0.95),
                                    showDivider: true
                                ) {
                                    Task {
                                        do {
                                            try await viewModel.updatePassword()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }

                                settingsButton(
                                    title: "update_email",
                                    icon: "envelope.badge",
                                    iconColor: Color(red: 0.2, green: 0.45, blue: 0.95),
                                    showDivider: false
                                ) {
                                    Task {
                                        do {
                                            try await viewModel.updateEmail()
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if viewModel.authUser?.isAnonymous == true {
                        glassSection {
                            VStack(spacing: 0) {
                                sectionHeader(title: "link_account", icon: "link.circle.fill")

                                settingsButton(
                                    title: "link_google_account",
                                    icon: "globe",
                                    iconColor: Color(red: 0.2, green: 0.45, blue: 0.95),
                                    showDivider: true
                                ) {
                                    Task {
                                        do {
                                            try await viewModel.linkGoogleAccount()
                                            print("success")
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }

                                settingsButton(
                                    title: "link_email_account",
                                    icon: "envelope",
                                    iconColor: Color(red: 0.2, green: 0.45, blue: 0.95),
                                    showDivider: false
                                ) {
                                    Task {
                                        do {
                                            try await viewModel.linkEmailAccount()
                                            print("success")
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("settings_title")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
    }

    @ViewBuilder
    private func glassSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.18))

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )

            VStack(spacing: 0) {
                content()
            }
            .padding(.vertical, 4)
        }
        .shadow(color: Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.12), radius: 14, x: 0, y: 7)
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.8))
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.8))
                .textCase(.uppercase)
                .tracking(0.6)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    private func settingsButton(
        title: LocalizedStringKey,
        icon: String,
        iconColor: Color,
        labelColor: Color = Color(red: 0.1, green: 0.1, blue: 0.25),
        showDivider: Bool,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(iconColor.opacity(0.12))
                            .frame(width: 34, height: 34)
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(iconColor)
                    }

                    Text(title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(labelColor)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.65).opacity(0.5))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            if showDivider {
                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.leading, 66)
                    .padding(.trailing, 18)
            }
        }
    }
}
#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}
