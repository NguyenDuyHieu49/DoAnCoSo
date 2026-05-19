// SignInEmailViewModel.swift
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

// Mật khẩu admin cứng – trong thực tế nên lưu bí mật hơn (Remote Config / Cloud Function)
private let kAdminSecretPassword = "040905"

@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    // Admin toggle
    @Published var isAdminMode: Bool = false
    @Published var adminPassword: String = ""
    @Published var adminPasswordError: String? = nil

    func signup() async throws {
        guard !email.isEmpty, !password.isEmpty else { return }

        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(
            userid: authDataResult.uid,
            isAnonymous: authDataResult.isAnonymous,
            email: authDataResult.email,
            photoUrl: authDataResult.photoUrl,
            dateCreated: Date(),
            role: .user           // tài khoản mới luôn là .user
        )
        try await UserManager.shared.createNewUser(user: user)
    }

    func signin() async throws {
        guard !email.isEmpty, !password.isEmpty else { return }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }

    /// Xác thực mật khẩu admin và nếu đúng thì ghi role=admin lên Firestore
    /// Trả về true nếu hợp lệ
    func verifyAdminAndUpgrade(uid: String) async -> Bool {
        guard adminPassword == kAdminSecretPassword else {
            adminPasswordError = "Mật khẩu admin không đúng"
            return false
        }
        adminPasswordError = nil
        // Ghi role admin lên Firestore để AuthState.fetchUserRole lấy được
        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(["role": UserRole.admin.rawValue], merge: true)
        } catch {
            print("[SignInEmailViewModel] verifyAdminAndUpgrade error:", error.localizedDescription)
        }
        return true
    }
}
