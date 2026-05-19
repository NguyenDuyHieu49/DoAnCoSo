// DBUser.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - User Role
enum UserRole: String, Codable {
    case user  = "user"
    case admin = "admin"
}

struct DBUser: Identifiable, Hashable, Codable {
    let userId: String
    var id: String { userId }

    var email: String?
    var displayName: String?
    var avatarURL: String?
    var providerId: String?
    var isAnonymous: Bool
    var isPremium: Bool
    var dateCreated: Date?
    var phoneNumber: String?
    var bio: String?
    var location: String?
    var role: UserRole

    var photoUrl: String? {
        get { avatarURL }
        set { avatarURL = newValue }
    }

    var isAdmin: Bool { role == .admin }

    // Compatibility initializer
    init(userid: String,
         isAnonymous: Bool = false,
         email: String? = nil,
         photoUrl: String? = nil,
         dateCreated: Date? = nil,
         isPremium: Bool = false,
         displayName: String? = nil,
         phoneNumber: String? = nil,
         bio: String? = nil,
         providerId: String? = nil,
         location: String? = nil,
         role: UserRole = .user) {
        self.userId = userid
        self.isAnonymous = isAnonymous
        self.email = email
        self.avatarURL = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.bio = bio
        self.providerId = providerId
        self.location = location
        self.role = role
    }

    // Preferred initializer
    init(userId: String,
         isAnonymous: Bool = false,
         email: String? = nil,
         avatarURL: String? = nil,
         providerId: String? = nil,
         isPremium: Bool = false,
         dateCreated: Date? = nil,
         phoneNumber: String? = nil,
         displayName: String? = nil,
         bio: String? = nil,
         location: String? = nil,
         role: UserRole = .user) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.avatarURL = avatarURL
        self.providerId = providerId
        self.isPremium = isPremium
        self.dateCreated = dateCreated
        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.bio = bio
        self.location = location
        self.role = role
    }

    // Init from Firestore data
    init(id: String, data: [String: Any]) throws {
        self.userId = id
        self.email = data["email"] as? String
        self.avatarURL = data["avatarURL"] as? String ?? data["photoUrl"] as? String ?? data["photoURL"] as? String
        self.displayName = data["displayName"] as? String
        self.providerId = data["providerId"] as? String
        self.isAnonymous = data["isAnonymous"] as? Bool ?? false
        self.isPremium = data["isPremium"] as? Bool ?? false
        self.phoneNumber = data["phoneNumber"] as? String
        self.bio = data["bio"] as? String
        self.location = data["location"] as? String
        if let roleStr = data["role"] as? String, let r = UserRole(rawValue: roleStr) {
            self.role = r
        } else {
            self.role = .user
        }
        if let ts = data["dateCreated"] as? Timestamp {
            self.dateCreated = ts.dateValue()
        } else if let d = data["dateCreated"] as? Date {
            self.dateCreated = d
        } else if let ts = data["createdAt"] as? Timestamp {
            self.dateCreated = ts.dateValue()
        } else {
            self.dateCreated = nil
        }
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "isAnonymous": isAnonymous,
            "isPremium": isPremium,
            "role": role.rawValue
        ]
        if let email       { dict["email"]       = email }
        if let displayName { dict["displayName"] = displayName }
        if let avatarURL   { dict["avatarURL"] = avatarURL; dict["photoUrl"] = avatarURL }
        if let providerId  { dict["providerId"]  = providerId }
        if let phoneNumber { dict["phoneNumber"] = phoneNumber }
        if let bio         { dict["bio"]         = bio }
        if let location    { dict["location"]    = location }
        if let dateCreated {
            dict["dateCreated"] = Timestamp(date: dateCreated)
        } else {
            dict["dateCreated"] = FieldValue.serverTimestamp()
        }
        return dict
    }

    init(from authUser: User) {
        self.userId = authUser.uid
        self.email = authUser.email
        self.displayName = authUser.displayName
        self.avatarURL = authUser.photoURL?.absoluteString
        self.providerId = authUser.providerData.first?.providerID
        self.isAnonymous = authUser.isAnonymous
        self.isPremium = false
        self.dateCreated = nil
        self.phoneNumber = authUser.phoneNumber
        self.bio = nil
        self.location = nil
        self.role = .user
    }

    func hash(into hasher: inout Hasher) { hasher.combine(userId) }
    static func == (lhs: DBUser, rhs: DBUser) -> Bool { lhs.userId == rhs.userId }
}
