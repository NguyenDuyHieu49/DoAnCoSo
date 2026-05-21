//
//  ListingDetailViewModel.swift
//  Hotelia
//
//  Created by Macbook Pro on 20/5/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
@MainActor
final class ListingDetailViewModel: ObservableObject {

    static let sampleReviews: [Review] = [
        Review(id: "sample1", authorId: nil, authorName: "Ronaldo và Messi", rating: 4.5, comment: "Phòng sạch, nhân viên thân thiện. View đẹp buổi sáng.", createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, likes: 3, isLikedByCurrentUser: false),
        Review(id: "sample2", authorId: nil, authorName: "Sơn Tùng MTP", rating: 5.0, comment: "Dịch vụ tuyệt vời, bữa sáng ngon. Sẽ quay lại.", createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, likes: 5, isLikedByCurrentUser: false),
        Review(id: "sample3", authorId: nil, authorName: "Donald Trump", rating: 4.0, comment: "Phòng rộng, hơi ồn vào ban đêm nhưng tổng thể ổn.", createdAt: Calendar.current.date(byAdding: .day, value: -12, to: Date())!, likes: 1, isLikedByCurrentUser: false)
    ]

    @Published var reviews: [Review] = []
    @Published var selectedRoom: String? = nil
    @Published var checkInDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @Published var checkOutDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
    @Published var isProcessing: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var navigateToHistory: Bool = false
    @Published var currentReviewIndex: Int = 0

    func toggleLike(reviewId: String) {
        if let idx = reviews.firstIndex(where: { $0.id == reviewId }) {
            reviews[idx].isLikedByCurrentUser.toggle()
            reviews[idx].likes = reviews[idx].isLikedByCurrentUser
                ? reviews[idx].likes + 1
                : max(0, reviews[idx].likes - 1)
            return
        }
        var samples = Self.sampleReviews
        if let sIdx = samples.firstIndex(where: { $0.id == reviewId }) {
            samples[sIdx].isLikedByCurrentUser.toggle()
            samples[sIdx].likes = samples[sIdx].isLikedByCurrentUser
                ? samples[sIdx].likes + 1
                : max(0, samples[sIdx].likes - 1)
            reviews = samples
        }
    }

    func submitReview(authorName: String, rating: Double, comment: String) {
        let review = Review(
            id: UUID().uuidString,
            authorId: nil,
            authorName: authorName.isEmpty ? "Khách" : authorName,
            rating: rating,
            comment: comment,
            createdAt: Date(),
            likes: 0,
            isLikedByCurrentUser: false
        )
        reviews.insert(review, at: 0)
        currentReviewIndex = 0
    }

    func placeBooking(listing: Listing) async {
        guard !isProcessing else { return }
        isProcessing = true

        guard let selectedRoom, let price = listing.pricePerNight?[selectedRoom] else {
            alertMessage = "choose_room_to_book."
            showAlert = true
            isProcessing = false
            return
        }
        guard checkOutDate > checkInDate else {
            alertMessage = "out_after_in"
            showAlert = true
            isProcessing = false
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "signin_book."
            showAlert = true
            isProcessing = false
            return
        }

        do {
            let db = Firestore.firestore()
            let bookingRef = db.collection("bookings").document()
            let bookingData: [String: Any] = [
                "userId": userId,
                "hotelId": listing.id,
                "hotelName": listing.title,
                "hotelAddress": listing.address,
                "roomType": selectedRoom,
                "price": price,
                "currency": "VND",
                "checkIn": Timestamp(date: checkInDate),
                "checkOut": Timestamp(date: checkOutDate),
                "createdAt": Timestamp(date: Date())
            ]
            try await bookingRef.setData(bookingData)
            NotificationCenter.default.post(name: .didCreateBooking, object: nil, userInfo: [
                "bookingId": bookingRef.documentID,
                "hotelId": listing.id,
                "roomType": selectedRoom,
                "price": price,
                "checkIn": checkInDate,
                "checkOut": checkOutDate
            ])
            isProcessing = false
            navigateToHistory = true
        } catch {
            alertMessage = "booking_failed."
            showAlert = true
            isProcessing = false
        }
    }
}
