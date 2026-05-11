// ProfileViewModel.swift
import Foundation
import FirebaseAuth
import Combine
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: DBUser? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func loadCurrentUser() async {
        do {
            isLoading = true
            errorMessage = nil
            guard let uid = Auth.auth().currentUser?.uid else {
                errorMessage = "Chưa đăng nhập"
                user = nil
                isLoading = false
                return
            }
            if let fetched = try await UserManager.shared.getUser(userId: uid) {
                self.user = fetched
            } else {
                // nếu chưa có document, tạo từ auth user
                if let authUser = Auth.auth().currentUser {
                    let dbUser = DBUser(from: authUser)
                    try await UserManager.shared.createNewUser(user: dbUser)
                    self.user = dbUser
                } else {
                    self.user = nil
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            user = nil
        }
        isLoading = false
    }

    func refresh() async {
        await loadCurrentUser()
    }

    func updateLocalUser(_ newUser: DBUser) {
        self.user = newUser
    }
}
