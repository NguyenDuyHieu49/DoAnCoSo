//
//  SampleReview.swift
//  Hotelia
//
//  Created by Macbook Pro on 14/5/26.
//

import Foundation
struct Review: Identifiable, Hashable {
    let id: String
    let authorId: String?
    let authorName: String
    let rating: Double
    let comment: String
    let createdAt: Date
    var likes: Int
    var isLikedByCurrentUser: Bool

    init(id: String = UUID().uuidString,
         authorId: String? = nil,
         authorName: String,
         rating: Double,
         comment: String,
         createdAt: Date = Date(),
         likes: Int = 0,
         isLikedByCurrentUser: Bool = false) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
        self.likes = likes
        self.isLikedByCurrentUser = isLikedByCurrentUser
    }
}
