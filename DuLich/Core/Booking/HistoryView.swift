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
                        Button("Thử lại") { Task { await vm.fetchOnce() } }
                    }.padding()
                } else if vm.bookings.isEmpty {
                    VStack(spacing: 8) {
                        Text("Chưa có lịch sử đặt phòng")
                            .font(.headline)
                        Text("Bạn chưa đặt phòng nào.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }.padding()
                } else {
                    List(vm.bookings) { booking in
                        NavigationLink(destination: BookingDetailView(booking: booking)) {
                            BookingRowView(booking: booking)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Lịch sử")
            .onAppear { vm.startListening() }
            .onDisappear { vm.stopListening() }
        }
    }
}

struct BookingRowView: View {
    let booking: DBBooking

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(booking.hotelName).font(.headline)
                if let addr = booking.hotelAddress { Text(addr).font(.caption).foregroundColor(.secondary) }
                Text("\(booking.roomType) • \(Int(booking.price)) \(booking.currency)")
                    .font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(Self.dateFormatter.string(from: booking.checkIn))
                    .font(.caption2)
                if let created = booking.createdAt {
                    Text(Self.createdFormatter.string(from: created))
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; return f
    }()

    private static let createdFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .short; f.timeStyle = .short; return f
    }()
}
