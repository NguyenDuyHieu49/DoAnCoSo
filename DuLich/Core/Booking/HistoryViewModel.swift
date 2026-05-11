// HistoryViewModel.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var bookings: [DBBooking] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var listener: ListenerRegistration?

    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.bookings = []
            return
        }

        isLoading = true
        errorMessage = nil
        listener?.remove()
        listener = Firestore.firestore()
            .collection("bookings")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    guard let snap = snapshot else {
                        self.bookings = []
                        return
                    }
                    self.bookings = snap.documents.compactMap { doc in
                        try? DBBooking(id: doc.documentID, data: doc.data())
                    }
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    deinit {
        listener?.remove()
    }

    // one-time fetch
    func fetchOnce() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let items = try await BookingManager.shared.fetchBookings(forUserId: uid)
            self.bookings = items
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
