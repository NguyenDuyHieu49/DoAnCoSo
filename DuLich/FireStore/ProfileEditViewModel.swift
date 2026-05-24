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

