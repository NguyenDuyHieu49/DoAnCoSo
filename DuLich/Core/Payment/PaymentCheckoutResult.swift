import Foundation

struct PaymentCheckoutResult {
    let transactionId: String
    let orderId: String
    let method: PaymentMethod
}
