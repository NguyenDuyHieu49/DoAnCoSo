// AuthState.swift
import Foundation
import FirebaseAuth
import Combine
@MainActor
final class AuthState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isAnonymous: Bool = false
    @Published var uid: String? = nil
    @Published var email: String? = nil

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        startListening()
    }

    func startListening() {
        // Remove existing listener if any
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
            handle = nil
        }

        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                if let u = user {
                    self.isAnonymous = u.isAnonymous
                    self.isSignedIn = true
                    self.uid = u.uid
                    self.email = u.email
                } else {
                    self.isAnonymous = false
                    self.isSignedIn = false
                    self.uid = nil
                    self.email = nil
                }
            }
        }
    }

    func stopListening() {
        // This method is MainActor-isolated because the class is @MainActor
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
            handle = nil
        }
    }

    deinit {
        // deinit is nonisolated; call stopListening asynchronously on the MainActor
        Task { @MainActor in
            self.stopListening()
        }
    }
}
