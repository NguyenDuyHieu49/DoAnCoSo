import Foundation

final class PaymentService {
    static let shared = PaymentService()
    private init() {}

    func processPayment(
        method: PaymentMethod,
        amount: Double,
        currency: String = "VND",
        orderInfo: String
    ) async throws -> String {
        guard currency == "VND" else {
            throw PaymentError.unsupportedCurrency
        }

        let amountInt = Int(amount.rounded())
        let orderId = "HTL\(Int(Date().timeIntervalSince1970))\(Int.random(in: 1000...9999))"

        switch method {
        case .momo:
            let createResponse = try await MoMoGateway.shared.createPayment(
                amount: amountInt,
                orderInfo: orderInfo,
                orderId: orderId
            )
            let checkout = try await MoMoGateway.shared.openCheckout(response: createResponse)
            return checkout.transactionId

        case .vnpay:
            let paymentURL = try VNPayGateway.shared.buildPaymentURL(
                amount: amountInt,
                orderInfo: orderInfo,
                txnRef: orderId
            )
            let checkout = try await PaymentCheckoutCoordinator.shared.startWebCheckout(
                url: paymentURL,
                callbackScheme: PaymentConfig.returnScheme,
                method: .vnpay
            )
            return checkout.transactionId

        case .bankTransfer, .cash:
            try await Task.sleep(nanoseconds: method == .cash ? 300_000_000 : 600_000_000)
            let transactionId = "\(method.rawValue.uppercased())-\(UUID().uuidString.prefix(8).uppercased())"
            print("[PaymentService] \(method.displayName) | \(amountInt) \(currency) | \(orderInfo) | tx: \(transactionId)")
            return transactionId
        }
    }
}
