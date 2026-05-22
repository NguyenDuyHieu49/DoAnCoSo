// ProfileView.swift
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @State private var showEdit = false
    @State private var showSignIn = false
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
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
                    .frame(width: 280, height: 280)
                    .blur(radius: 65)
                    .offset(x: -110, y: -200)

                Circle()
                    .fill(Color(red: 0.4, green: 0.65, blue: 1.0).opacity(0.25))
                    .frame(width: 210, height: 210)
                    .blur(radius: 52)
                    .offset(x: 130, y: 240)

                Group {
                    if vm.isLoading {
                        loadingView
                    } else if let err = vm.errorMessage, vm.user == nil {
                        errorView(err)
                    } else if let user = vm.user {
                        userContentView(user: user)
                    } else {
                        notSignedInView
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Hồ sơ")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task { await vm.loadCurrentUser() }
            .sheet(isPresented: $showEdit) {
                if let _ = vm.user {
                    ProfileEditView(user: Binding(get: { vm.user }, set: { vm.updateLocalUser($0!) }))
                }
            }
            .fullScreenCover(isPresented: $showSignIn) {
                NavigationStack {
                    SignInEmailView(showSignInView: $showSignIn)
                }
            }
            .alert("Lỗi", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 72, height: 72)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
            }
            Text("Đang tải...")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 80, height: 80)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 34, weight: .light))
                    .foregroundColor(.white)
            }
            VStack(spacing: 8) {
                Text("Đã xảy ra lỗi")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(message)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            glassButton(title: "Thử lại", icon: "arrow.clockwise") {
                Task { await vm.loadCurrentUser() }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notSignedInView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 90, height: 90)
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.white)
            }
            VStack(spacing: 8) {
                Text("Chưa đăng nhập")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Đăng nhập để xem thông tin hồ sơ của bạn.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            glassButton(title: "Đăng nhập", icon: "arrow.right.circle") {
                showSignIn = true
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func userContentView(user: DBUser) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard(user: user)
                infoCard(user: user)
                actionButtons(user: user)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
    }

    @ViewBuilder
    private func headerCard(user: DBUser) -> some View {
        ZStack {
            glassCardBackground()

            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.45, blue: 0.95),
                                    Color(red: 0.35, green: 0.6, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    if let url = user.avatarURL, let u = URL(string: url) {
                        AsyncImage(url: u) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            default:
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(.white)
                    }

                    Circle()
                        .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 80, height: 80)
                }
                .shadow(color: Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.35), radius: 10, x: 0, y: 5)

                VStack(alignment: .leading, spacing: 6) {
                    Text(user.displayName ?? String(localized:"us_er"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.25))
                        .lineLimit(1)

                    HStack(spacing: 5) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.7))
                        Text(user.email ?? "Chưa có email")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.85))
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
        .shadow(color: Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.13), radius: 14, x: 0, y: 7)
    }

    private func infoCard(user: DBUser) -> some View {
        ZStack {
            glassCardBackground()

            VStack(spacing: 0) {
                infoRow(
                    label: "phone_number",
                    icon: "phone.fill",
                    value: user.phoneNumber ?? String(localized:"not_available")
                )

                Divider()
                    .background(Color.white.opacity(0.5))
                    .padding(.horizontal, 4)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "text.quote")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.7))
                        Text("Giới thiệu")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.8))
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    Text(user.bio ?? String(localized: "not_available"))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.3).opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
        }
        .shadow(color: Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.13), radius: 14, x: 0, y: 7)
    }

    private func infoRow(label: LocalizedStringKey, icon: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.7))
                .frame(width: 20)

            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5).opacity(0.8))
                .textCase(.uppercase)
                .tracking(0.5)

            Spacer()

            Text(value)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.3))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private func actionButtons(user: DBUser) -> some View {
        VStack(spacing: 12) {
            Button {
                showEdit = true
            } label: {
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
                        .shadow(color: Color(red: 0.2, green: 0.45, blue: 0.95).opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.22), Color.white.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 54)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Chỉnh sửa hồ sơ")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func glassCardBackground() -> some View {
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
        }
    }

    private func glassButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 13)
            .background(
                ZStack {
                    Capsule().fill(Color.white.opacity(0.22))
                    Capsule().strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                }
            )
            .shadow(color: Color.blue.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
}

