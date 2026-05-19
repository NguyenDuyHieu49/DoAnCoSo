// AuthState.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isAnonymous: Bool = false
    @Published var uid: String? = nil
    @Published var email: String? = nil
    @Published var userRole: UserRole = .user   // ← role hiện tại của user

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        startListening()
    }

    func startListening() {
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
            handle = nil
        }

        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                if let u = user {
                    self.isAnonymous = u.isAnonymous
                    self.isSignedIn  = true
                    self.uid         = u.uid
                    self.email       = u.email
                    // Fetch role từ Firestore
                    await self.fetchUserRole(uid: u.uid)
                } else {
                    self.isAnonymous = false
                    self.isSignedIn  = false
                    self.uid         = nil
                    self.email       = nil
                    self.userRole    = .user
                }
            }
        }
    }

    private func fetchUserRole(uid: String) async {
        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            print("[AuthState] fetchUserRole raw data:", doc.data() ?? "nil")  // ← thêm dòng này
            if let roleStr = doc.data()?["role"] as? String,
               let role = UserRole(rawValue: roleStr) {
                self.userRole = role
                print("[AuthState] userRole set to:", role)  // ← thêm dòng này
            } else {
                self.userRole = .user
                print("[AuthState] userRole fallback to .user")  // ← thêm dòng này
            }
        } catch {
            print("[AuthState] fetchUserRole error:", error.localizedDescription)
            self.userRole = .user
        }
    }

    /// Gọi sau khi admin đăng nhập thành công bằng mật khẩu admin
    func upgradeToAdmin() {
        self.userRole = .admin
    }

    var isAdmin: Bool { userRole == .admin }

    func stopListening() {
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
            handle = nil
        }
    }

    deinit {
        Task { @MainActor in self.stopListening() }
    }
}
