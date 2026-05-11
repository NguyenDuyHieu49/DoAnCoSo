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
            Group {
                if vm.isLoading {
                    ProgressView("Đang tải...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let err = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Lỗi: \(err)").foregroundColor(.red)
                        Button("Thử lại") { Task { await vm.loadCurrentUser() } }
                    }
                    .padding()
                } else if let user = vm.user {
                    ScrollView {
                        VStack(spacing: 16) {
                            header(user: user)
                            infoCard(user: user)
                            actionButtons(user: user)
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("Chưa có thông tin người dùng")
                            .foregroundColor(.secondary)
                        Button("Đăng nhập") { showSignIn = true }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Hồ sơ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEdit = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .disabled(vm.user == nil)
                }
            }
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

    @ViewBuilder
    private func header(user: DBUser) -> some View {
        HStack(spacing: 16) {
            if let url = user.avatarURL, let u = URL(string: url) {
                AsyncImage(url: u) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure: Image(systemName: "person.crop.circle.fill")
                    @unknown default: Image(systemName: "person.crop.circle")
                    }
                }
                .frame(width: 88, height: 88)
                .clipShape(Circle())
                .shadow(radius: 4)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 88, height: 88)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(user.displayName ?? "Người dùng")
                    .font(.title2).bold()
                Text(user.email ?? "Chưa có email")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            Spacer()
        }
    }

    private func infoCard(user: DBUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Số điện thoại").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text(user.phoneNumber ?? "Chưa có").font(.subheadline)
            }
            Divider()
            HStack {
                Text("Giới thiệu").font(.caption).foregroundColor(.secondary)
                Spacer()
            }
            if let bio = user.bio {
                Text(bio).foregroundColor(.secondary).font(.subheadline)
            } else {
                Text("Chưa có").foregroundColor(.secondary).font(.subheadline)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }

    private func actionButtons(user: DBUser) -> some View {
        VStack(spacing: 12) {
            Button {
                showEdit = true
            } label: {
                Label("Chỉnh sửa hồ sơ", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(role: .destructive) {
                Task {
                    do {
                        try await AuthenticationManager.shared.signOut()
                        // Auth listener ở AuthState sẽ xử lý chuyển màn
                    } catch {
                        vm.errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            } label: {
                Text("Đăng xuất")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(0.8)))
            }
        }
    }
}
