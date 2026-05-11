import SwiftUI

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

    private func isValidEmail(_ email: String) -> Bool {
        // Basic email validation regex
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegEx, options: .regularExpression) != nil
    }

    private func isValidPhoneNumber(_ phone: String) -> Bool {
        // Basic phone validation: digits only and length between 7 and 15
        let digitsOnly = phone.filter { $0.isNumber }
        return digitsOnly.count >= 7 && digitsOnly.count <= 15 && digitsOnly.count == phone.count
    }

    func buildUpdatedUser(from user: DBUser?) -> DBUser? {
        guard let user else { return nil }
        // Basic validations
        if !email.isEmpty && !isValidEmail(email) {
            errorMessage = "Email không hợp lệ"
            return nil
        }
        if !phoneNumber.isEmpty && !isValidPhoneNumber(phoneNumber) {
            errorMessage = "Số điện thoại không hợp lệ"
            return nil
        }
        errorMessage = nil
        return DBUser(
            userId: user.userId,
            isAnonymous: user.isAnonymous,
            email: email.isEmpty ? nil : email,
            photoUrl: user.photoUrl,
            dateCreated: user.dateCreated,
            isPremium: user.isPremium,
            displayName: displayName.isEmpty ? nil : displayName,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            bio: bio.isEmpty ? nil : bio
        )
    }

    func save(user: DBUser?) async throws -> DBUser? {
        guard let updated = buildUpdatedUser(from: user) else {
            if errorMessage == nil {
                errorMessage = "Không thể lưu thông tin."
            }
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
    @StateObject private var viewModel = ProfileEditViewModel()

    var body: some View {
        Form {
            Section(header: Text("Thông tin cơ bản")) {
                TextField("Tên hiển thị", text: $viewModel.displayName)
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Số điện thoại", text: $viewModel.phoneNumber)
                    .keyboardType(.phonePad)
            }
            Section(header: Text("Giới thiệu")) {
                TextEditor(text: $viewModel.bio)
                    .frame(minHeight: 120)
            }
            if let error = viewModel.errorMessage {
                Section { Text(error).foregroundColor(.red) }
            }
        }
        .navigationTitle("Chỉnh sửa hồ sơ")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: save) {
                    if viewModel.isSaving { ProgressView() } else { Text("Lưu") }
                }
                .disabled(viewModel.isSaving)
            }
        }
        .onAppear { viewModel.load(from: user) }
    }

    private func save() {
        Task {
            do {
                let refreshed = try await viewModel.save(user: user)
                if let refreshed = refreshed {
                    self.user = refreshed
                    dismiss()
                }
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(user: .constant(DBUser(userId: "123", isAnonymous: false, email: "user@example.com", photoUrl: nil, dateCreated: .now, isPremium: false, displayName: "User", phoneNumber: "0123456789", bio: "Xin chào!")))
    }
}
