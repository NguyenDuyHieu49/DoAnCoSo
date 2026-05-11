// UserManager.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

final class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()
    private init() {}

    // Fetch user by id
    func getUser(userId: String) async throws -> DBUser? {
        let docRef = db.collection("users").document(userId)
        let snapshot = try await docRef.getDocument()
        guard let data = snapshot.data() else { return nil }
        return try DBUser(id: snapshot.documentID, data: data)
    }

    // Update user document (merge)
    func updateUser(user: DBUser) async throws {
        let docRef = db.collection("users").document(user.userId)
        let data = user.toDict()
        try await docRef.setData(data, merge: true)
    }

    // Create new user document from DBUser
    // Provide external label `user:` to match existing call sites like createNewUser(user: user)
    func createNewUser(user: DBUser) async throws -> DBUser {
        let docRef = db.collection("users").document(user.userId)
        let data = user.toDict()
        try await docRef.setData(data, merge: true)
        return user
    }

    // Convenience: create from Firebase Auth user
    func createNewUser(from authUser: User) async throws -> DBUser {
        let dbUser = DBUser(from: authUser)
        return try await createNewUser(user: dbUser)
    }
}
