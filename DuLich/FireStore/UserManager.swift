//
//  UserManager.swift
//  DuLich
//
//  Created by Macbook Pro on 9/5/26.
//

import Foundation
import FirebaseFirestore
internal import FirebaseSharedSwift

struct DBUser: Codable {

    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
    }
}
final class UserManager{
    
    static let shared = UserManager()
    private init(){}
    
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userId: String) -> DocumentReference{
        userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    func createNewUser(user: DBUser) async throws{
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    //    func createNewUser(auth: AuthDataResultModel) async throws{
    //        var userData: [String:Any] = [
    //            "user_id" : auth.uid,
    //            "is_anonymous" : auth.isAnonymous,
    //            "date_created" : Timestamp(),
    //        ]
    //        if let email = auth.email{
    //            userData["email"] = email
    //        }
    //        if let photoUrl = auth.photoUrl{
    //            userData["photo_url"] = photoUrl
    //        }
    //        
    //        try await userDocument(userId: auth.uid).setData(userData, merge: false)
    //        try await Firestore.firestore().collection("users").document( auth.uid).setData(userData, merge: false)
    //        
    //    }
    func getUser(userId: String) async throws -> DBUser {
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .getDocument(as : DBUser.self)
    }
}

    
//    func getUser(userId: String) async throws -> DBUser {
//        
//        let snapshot = try await Firestore.firestore()
//            .collection("users")
//            .document(userId)
//            .getDocument()
        
//        guard let data = snapshot.data() else {
//            throw URLError(.badServerResponse)
//        }
//        
//        guard let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        
//        let timestamp = data["date_created"] as? Timestamp
//        let dateCreated = timestamp?.dateValue()
//        
//        return DBUser(
//            userId: userId,
//            isAnonymous: isAnonymous,
//            email: email,
//            photoUrl: photoUrl,
//            dateCreated: dateCreated
//        )
//    }
//}
