import SwiftUI

struct PaymentView: View {
    let amount: Double
    let currency: String
    let hotelName: String
    let roomType: String
    let onConfirm: (PaymentMethod) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedMethod: PaymentMethod = .momo

    var body: some View {
        NavigationStack {
            ZStack {
                Glass.pageBg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        summaryCard
                        methodsCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("payment_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                confirmBar
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("order_details")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Glass.textTertiary)
                .textCase(.uppercase)
                .tracking(0.6)

            Text(hotelName)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Glass.textPrimary)

            Text(roomType)
                .font(.system(size: 13))
                .foregroundStyle(Glass.textSecondary)

            HStack {
                Text("total_payment")
                    .font(.system(size: 14))
                    .foregroundStyle(Glass.textSecondary)
                Spacer()
                Text("\(Int(amount)) \(currency)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Glass.accent)
            }
            .padding(.top, 4)
        }
        .padding(18)
        .glassCard(prominent: true)
    }

    private var methodsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("payment_methods")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Glass.textTertiary)
                .textCase(.uppercase)
                .tracking(0.6)

            ForEach(PaymentMethod.allCases) { method in
                paymentMethodRow(method)
            }
        }
        .padding(18)
        .glassCard()
    }

    private func paymentMethodRow(_ method: PaymentMethod) -> some View {
        let isSelected = selectedMethod == method
        return Button {
            withAnimation(.spring(response: 0.25)) { selectedMethod = method }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: method.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(isSelected ? .white : methodColor(method))
                    .frame(width: 38, height: 38)
                    .background(isSelected ? methodColor(method) : methodColor(method).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(method.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Glass.textPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Glass.accent : Glass.textTertiary.opacity(0.5))
            }
            .padding(12)
            .background(isSelected ? Glass.accentLight : Color.white.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: Glass.cornerMd))
            .overlay(
                RoundedRectangle(cornerRadius: Glass.cornerMd)
                    .stroke(isSelected ? Glass.accent.opacity(0.4) : Glass.cardStroke2, lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }

    private func methodColor(_ method: PaymentMethod) -> Color {
        switch method {
        case .momo: return Color(red: 0.68, green: 0.05, blue: 0.42)
        case .vnpay: return Color(red: 0.0, green: 0.45, blue: 0.75)
        case .bankTransfer: return Color(red: 0.15, green: 0.40, blue: 0.90)
        case .cash: return Color(red: 0.13, green: 0.72, blue: 0.44)
        }
    }

    private var confirmBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(red: 0.70, green: 0.80, blue: 1.00).opacity(0.30))
                .frame(height: 0.6)

            Button {
                onConfirm(selectedMethod)
                dismiss()
            } label: {
                Text("confirm_payment")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Glass.accent)
                    .clipShape(RoundedRectangle(cornerRadius: Glass.cornerMd))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
}
