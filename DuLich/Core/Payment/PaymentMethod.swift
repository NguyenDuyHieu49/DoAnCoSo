import Foundation

enum PaymentMethod: String, CaseIterable, Identifiable {
    case momo
    case vnpay
    case bankTransfer
    case cash

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .momo: return "MoMo"
        case .vnpay: return "VNPay"
        case .bankTransfer: return String(localized: "bank_transfer")
        case .cash: return String(localized: "cash_at_hotel")
        }
    }

    var iconName: String {
        switch self {
        case .momo: return "wallet.pass.fill"
        case .vnpay: return "creditcard.fill"
        case .bankTransfer: return "building.columns.fill"
        case .cash: return "banknote.fill"
        }
    }

    var accentColorName: String {
        switch self {
        case .momo: return "momo"
        case .vnpay: return "vnpay"
        case .bankTransfer: return "bank"
        case .cash: return "cash"
        }
    }
}

enum PaymentStatus: String {
    case pending
    case completed
    case failed
}

enum PaymentError: LocalizedError {
    case processingFailed
    case cancelled
    case unsupportedCurrency
    case invalidAmount(minimum: Int)
    case gatewayRejected(message: String)

    var errorDescription: String? {
        switch self {
        case .processingFailed:
            return String(localized: "payment_failed")
        case .cancelled:
            return String(localized: "payment_cancelled")
        case .unsupportedCurrency:
            return String(localized: "vnd_only")
        case .invalidAmount(let minimum):
            return String(localized: "min_amount_vnd \(minimum.formatted())")
        case .gatewayRejected(let message):
            return message
        }
    }
}
