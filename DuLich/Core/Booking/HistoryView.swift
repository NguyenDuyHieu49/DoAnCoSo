// HistoryView.swift
import SwiftUI
import FirebaseFirestore

struct HistoryView: View {
    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Đang tải...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let err = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Lỗi: \(err)").foregroundColor(.red)
                        Button("Thử lại") { Task { await vm.load() } }
                    }
                    .padding()
                } else if vm.bookings.isEmpty {
                    VStack(spacing: 8) {
                        Text("Chưa có lịch sử đặt phòng")
                            .font(.headline)
                        Text("Bạn chưa đặt phòng nào.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Tải lại") { Task { await vm.load() } }
                            .padding(.top, 8)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(vm.bookings) { booking in
                            NavigationLink(destination: BookingDetailView(booking: booking)) {
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { await vm.load() }
                }
            }
            .navigationTitle("Lịch sử")
            .onAppear { Task { await vm.load() } }
        }
    }
}
