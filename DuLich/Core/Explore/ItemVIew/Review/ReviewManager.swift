//
//  ReviewManager.swift
//  Hotelia
//
//  Created by Macbook Pro on 14/5/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class ReviewsManager {
    static let shared = ReviewsManager()
    private let db = Firestore.firestore()
    private init() {}

    func fetchReviews(for listingId: String) async throws -> [Review] {
        let q = db.collection("reviews")
            .whereField("listingId", isEqualTo: listingId)
            .order(by: "createdAt", descending: true)
        let snapshot = try await q.getDocuments()
        var loaded: [Review] = []
        let currentUid = Auth.auth().currentUser?.uid

        for doc in snapshot.documents {
            let data = doc.data()
            let id = doc.documentID
            let authorId = data["authorId"] as? String
            let authorName = data["authorName"] as? String ?? "Khách"
            let rating = (data["rating"] as? Double) ?? (data["rating"] as? NSNumber)?.doubleValue ?? 0.0
            let comment = data["comment"] as? String ?? ""
            let likes = (data["likes"] as? Int) ?? (data["likes"] as? NSNumber)?.intValue ?? 0
            var createdAt = Date()
            if let ts = data["createdAt"] as? Timestamp {
                createdAt = ts.dateValue()
            }

            var isLiked = false
            if let uid = currentUid {
                let likeDoc = try await db.collection("reviews").document(id).collection("likes").document(uid).getDocument()
                isLiked = likeDoc.exists
            }

            let review = Review(id: id,
                                authorId: authorId,
                                authorName: authorName,
                                rating: rating,
                                comment: comment,
                                createdAt: createdAt,
                                likes: likes,
                                isLikedByCurrentUser: isLiked)
            loaded.append(review)
        }
        return loaded
    }

    func submitReview(listingId: String, authorName: String, rating: Double, comment: String) async throws -> Review {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ReviewsManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        let reviewsCol = db.collection("reviews")
        let newDoc = reviewsCol.document()
        let data: [String: Any] = [
            "listingId": listingId,
            "authorId": uid,
            "authorName": authorName,
            "rating": rating,
            "comment": comment,
            "createdAt": FieldValue.serverTimestamp(),
            "likes": 0
        ]
        try await newDoc.setData(data)
        let createdSnap = try await newDoc.getDocument()
        var createdAt = Date()
        if let ts = createdSnap.data()?["createdAt"] as? Timestamp {
            createdAt = ts.dateValue()
        }
        return Review(id: newDoc.documentID,
                      authorId: uid,
                      authorName: authorName,
                      rating: rating,
                      comment: comment,
                      createdAt: createdAt,
                      likes: 0,
                      isLikedByCurrentUser: false)
    }

    func toggleLike(reviewId: String) async throws -> (isLiked: Bool, likes: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "ReviewsManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        let reviewRef = db.collection("reviews").document(reviewId)
        let likeRef = reviewRef.collection("likes").document(uid)
        var resultIsLiked = false
        var resultLikes = 0

        try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let reviewSnap = try transaction.getDocument(reviewRef)
                guard reviewSnap.exists else {
                    errorPointer?.pointee = NSError(domain: "ReviewsManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Review not found"])
                    return nil
                }
                let currentLikes = (reviewSnap.data()? ["likes"] as? Int) ?? (reviewSnap.data()? ["likes"] as? NSNumber)?.intValue ?? 0
                let likeSnap = try? transaction.getDocument(likeRef)

                if let likeSnap = likeSnap, likeSnap.exists {
                    transaction.deleteDocument(likeRef)
                    transaction.updateData(["likes": max(0, currentLikes - 1)], forDocument: reviewRef)
                    resultIsLiked = false
                    resultLikes = max(0, currentLikes - 1)
                } else {
                    transaction.setData(["createdAt": FieldValue.serverTimestamp()], forDocument: likeRef)
                    transaction.updateData(["likes": currentLikes + 1], forDocument: reviewRef)
                    resultIsLiked = true
                    resultLikes = currentLikes + 1
                }
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        })
        return (resultIsLiked, resultLikes)
    }
}

