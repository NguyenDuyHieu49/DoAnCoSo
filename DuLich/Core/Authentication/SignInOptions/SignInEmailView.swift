import SwiftUI
import Combine
import FirebaseAuth
struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    @EnvironmentObject private var authState: AuthState
 
    @State private var isLoading = false
    @State private var showAdminPasswordField = false
 
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
 
                    VStack(spacing: 8) {
                        Image(systemName: viewModel.isAdminMode
                              ? "person.badge.key.fill"
                              : "envelope.circle.fill")
                            .font(.system(size: 56, weight: .thin))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.8)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
                            .padding(.bottom, 4)
                            .animation(.spring(response: 0.4), value: viewModel.isAdminMode)
 
                        Text(viewModel.isAdminMode ? "Đăng nhập Admin" : "Welcome Back")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
 
                        Text(viewModel.isAdminMode
                             ? "Nhập thêm mật khẩu quản trị"
                             : "Sign in to continue")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 36)
 
                    VStack(spacing: 18) {
 
                        // Email field
                        inputField(
                            label: "Email",
                            icon: "envelope",
                            placeholder: "your@email.com",
                            text: Binding(get: { viewModel.email }, set: { viewModel.email = $0 }),
                            keyboard: .emailAddress,
                            secure: false
                        )
 
                        // Password field
                        inputField(
                            label: "Password",
                            icon: "lock",
                            placeholder: "••••••••",
                            text: Binding(get: { viewModel.password }, set: { viewModel.password = $0 }),
                            keyboard: .default,
                            secure: true
                        )
 
                        // ── Admin Toggle ────────────────────────────────────
                        adminToggleRow
 
                        // ── Admin Password field (animated) ─────────────────
                        if viewModel.isAdminMode {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Mật khẩu Admin", systemImage: "key.fill")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.3))
                                    .textCase(.uppercase)
                                    .tracking(0.8)
 
                                SecureField("Nhập mật khẩu quản trị...", text: Binding(
                                    get: { viewModel.adminPassword },
                                    set: { viewModel.adminPassword = $0 }
                                ))
                                .textContentType(.password)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color(red: 1.0, green: 0.95, blue: 0.8).opacity(0.9))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.7), lineWidth: 1.2)
                                        )
                                        .shadow(color: Color.orange.opacity(0.2), radius: 6, x: 0, y: 3)
                                )
 
                                if let err = viewModel.adminPasswordError {
                                    Label(err, systemImage: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.3))
                                        .padding(.top, 2)
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .push(from: .top).combined(with: .opacity),
                                removal: .push(from: .bottom).combined(with: .opacity)
                            ))
                        }
 
                        // ── Sign In Button ───────────────────────────────────
                        signInButton
                    }
                    .padding(24)
                    .background(glassCard)
                    .shadow(
                        color: Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.18),
                        radius: 30, x: 0, y: 16
                    )
                    .padding(.horizontal, 24)
                    .animation(.spring(response: 0.45, dampingFraction: 0.85), value: viewModel.isAdminMode)
 
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.isAdminMode ? "Đăng nhập Admin" : "Sign In With Email")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
 
    private var adminToggleRow: some View {
        Button {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                viewModel.isAdminMode.toggle()
                if !viewModel.isAdminMode {
                    viewModel.adminPassword = ""
                    viewModel.adminPasswordError = nil
                }
            }
        } label: {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(viewModel.isAdminMode
                              ? Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.25)
                              : Color.white.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: viewModel.isAdminMode ? "checkmark.shield.fill" : "shield")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.isAdminMode
                                         ? Color(red: 0.9, green: 0.65, blue: 0.1)
                                         : Color.white.opacity(0.7))
                }
 
                VStack(alignment: .leading, spacing: 2) {
                    Text("Đăng nhập với quyền Admin")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(viewModel.isAdminMode ? Color(red: 0.9, green: 0.65, blue: 0.1) : .white)
                    Text(viewModel.isAdminMode ? "Yêu cầu mật khẩu quản trị" : "Tick để truy cập tính năng admin")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                }
 
                Spacer()
 
                // Custom toggle indicator
                ZStack {
                    Capsule()
                        .fill(viewModel.isAdminMode
                              ? Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.8)
                              : Color.white.opacity(0.2))
                        .frame(width: 44, height: 26)
 
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                        .offset(x: viewModel.isAdminMode ? 9 : -9)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(viewModel.isAdminMode
                          ? Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.12)
                          : Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                viewModel.isAdminMode
                                    ? Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.5)
                                    : Color.white.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
 
    private var signInButton: some View {
        Button {
            Task {
                isLoading = true
                defer { isLoading = false }

                do { try await viewModel.signup() }
                catch {
                    do { try await viewModel.signin() }
                    catch {
                        print("[SignInEmailView] signin error:", error)
                        return
                    }
                }

                if viewModel.isAdminMode {
                    guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
                    let ok = await viewModel.verifyAdminAndUpgrade(uid: uid)
                    print("[SignIn] verifyAdminAndUpgrade result:", ok)  // ← thêm
                    if !ok { return }
                    authState.upgradeToAdmin()
                    print("[SignIn] authState.userRole after upgrade:", authState.userRole)  // ← thêm
                }
                showSignInView = false
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: viewModel.isAdminMode
                                ? [Color(red: 0.9, green: 0.6, blue: 0.1), Color(red: 1.0, green: 0.8, blue: 0.3)]
                                : [Color(red: 0.2, green: 0.45, blue: 0.95), Color(red: 0.35, green: 0.6, blue: 1.0)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(height: 54)
                    .shadow(
                        color: (viewModel.isAdminMode
                                ? Color.orange
                                : Color(red: 0.2, green: 0.45, blue: 0.95)).opacity(0.45),
                        radius: 12, x: 0, y: 6
                    )
 
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.white.opacity(0.0)],
                        startPoint: .top, endPoint: .center
                    ))
                    .frame(height: 54)
 
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isAdminMode ? "key.fill" : "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        Text(viewModel.isAdminMode ? "Đăng nhập Admin" : "Sign In")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .disabled(isLoading)
        .padding(.top, 4)
        .animation(.spring(response: 0.35), value: viewModel.isAdminMode)
    }
 
    // MARK: - Reusable input field
    @ViewBuilder
    private func inputField(
        label: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType,
        secure: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .textCase(.uppercase)
                .tracking(0.8)
 
            Group {
                if secure {
                    SecureField(placeholder, text: text)
                        .textContentType(.password)
                } else {
                    TextField(placeholder, text: text)
                        .textContentType(.emailAddress)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
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
    }
 
    // MARK: - Glass card background
    private var glassCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.18))
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.7), Color.white.opacity(0.15), Color.white.opacity(0.05)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
    }
}
 
#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
            .environmentObject(AuthState())
    }
}
 
