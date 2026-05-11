// ProfileEditView.swift
import SwiftUI
import Combine
@MainActor
final class ProfileEditViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var bio: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil

    func load(from user: DBUser?) {
        displayName = user?.displayName ?? ""
        email = user?.email ?? ""
        phoneNumber = user?.phoneNumber ?? ""
        bio = user?.bio ?? ""
    }

    private func isValidEmail(_ s: String) -> Bool {
        guard !s.isEmpty else { return true }
        let re = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return s.range(of: re, options: .regularExpression) != nil
    }

    func buildUpdatedUser(from user: DBUser?) -> DBUser? {
        guard let user = user else { return nil }
        if !isValidEmail(email) {
            errorMessage = "Email không hợp lệ"
            return nil
        }
        errorMessage = nil
        return DBUser(
            userId: user.userId,
            isAnonymous: user.isAnonymous,
            email: email.isEmpty ? user.email : email,
            avatarURL: user.avatarURL,
            providerId: user.providerId,
            isPremium: user.isPremium,
            dateCreated: user.dateCreated,
            phoneNumber: phoneNumber.isEmpty ? user.phoneNumber : phoneNumber,
            displayName: displayName.isEmpty ? user.displayName : displayName,
            bio: bio.isEmpty ? user.bio : bio
        )
    }

    func save(user: DBUser?) async throws -> DBUser? {
        guard let updated = buildUpdatedUser(from: user) else {
            if errorMessage == nil { errorMessage = "Không thể lưu" }
            return nil
        }
        isSaving = true
        defer { isSaving = false }
        try await UserManager.shared.updateUser(user: updated)
        return try await UserManager.shared.getUser(userId: updated.userId)
    }
}

struct ProfileEditView: View {
    @Binding var user: DBUser?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ProfileEditViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Thông tin cơ bản")) {
                    TextField("Tên hiển thị", text: $vm.displayName)
                    TextField("Email", text: $vm.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Số điện thoại", text: $vm.phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Giới thiệu")) {
                    TextEditor(text: $vm.bio)
                        .frame(minHeight: 120)
                }

                if let err = vm.errorMessage {
                    Section { Text(err).foregroundColor(.red) }
                }
            }
            .navigationTitle("Chỉnh sửa hồ sơ")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            do {
                                let refreshed = try await vm.save(user: user)
                                if let refreshed = refreshed {
                                    user = refreshed
                                    dismiss()
                                }
                            } catch {
                                vm.errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        if vm.isSaving { ProgressView() } else { Text("Lưu") }
                    }
                    .disabled(vm.isSaving)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ") { dismiss() }
                }
            }
            .onAppear { vm.load(from: user) }
        }
    }
}
