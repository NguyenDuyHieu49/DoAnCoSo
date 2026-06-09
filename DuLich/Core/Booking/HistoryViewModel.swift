// HistoryViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var bookings: [DBBooking] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private var notificationToken: NSObjectProtocol?

    init() {
        notificationToken = NotificationCenter.default.addObserver(
            forName: .didCreateBooking,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self = self else { return }
            if let bookingId = note.userInfo?["bookingId"] as? String {
                Task { await self.insertBookingById(bookingId) }
            } else {
                Task { await self.load() }
            }
        }
    }

    deinit {
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let uid = Auth.auth().currentUser?.uid else {
            bookings = []
            errorMessage = String(localized: "user_not_logged_in")
            return
        }

        do {
            try await BookingManager.shared.processNoShowCancellations(forUserId: uid)

            let snapshot = try await db.collection("bookings")
                .whereField("userId", isEqualTo: uid)
                .getDocuments()

            var items: [DBBooking] = []
            items.reserveCapacity(snapshot.documents.count)

            for doc in snapshot.documents {
                if let booking = try? DBBooking(id: doc.documentID, data: doc.data()) {
                    items.append(booking)
                } else {
                    print("Warning: unable to decode booking doc \(doc.documentID)")
                }
            }

            bookings = items.sorted {
                let aDate = $0.createdAt ?? Date.distantPast
                let bDate = $1.createdAt ?? Date.distantPast
                return aDate > bDate
            }
        } catch {
            errorMessage = String(localized: "history_load_error \(error.localizedDescription)")
            bookings = []
        }
    }

    private func insertBookingById(_ bookingId: String) async {
        do {
            let doc = try await db.collection("bookings").document(bookingId).getDocument()
            if let data = doc.data(),
               let booking = try? DBBooking(id: doc.documentID, data: data) {
                upsertBooking(booking)
            } else {
                await load()
            }
        } catch {
            print("Không fetch được booking mới: \(error.localizedDescription)")
            await load()
        }
    }

    private func upsertBooking(_ booking: DBBooking) {
        if let idx = bookings.firstIndex(where: { $0.id == booking.id }) {
            bookings[idx] = booking
        } else {
            bookings.insert(booking, at: 0)
        }
    }

}
