import Foundation

enum PaymentConfig {
    static var returnScheme: String {
        AppSecrets.string("PaymentReturnScheme", default: "hotelia")
    }

    static var momoReturnURL: String { "\(returnScheme)://payment/momo" }
    static var vnpayReturnURL: String { "\(returnScheme)://payment/vnpay" }

    static var momoPartnerCode: String { AppSecrets.string("MoMoPartnerCode") ?? "" }
    static var momoAccessKey: String { AppSecrets.string("MoMoAccessKey") ?? "" }
    static var momoSecretKey: String { AppSecrets.string("MoMoSecretKey") ?? "" }
    static var momoEndpoint: String {
        AppSecrets.string("MoMoEndpoint", default: "https://test-payment.momo.vn/v2/gateway/api/create")
    }
    static var momoIpnUrl: String { AppSecrets.string("MoMoIpnUrl") ?? "" }

    static var vnpayTmnCode: String { AppSecrets.string("VNPayTmnCode") ?? "" }
    static var vnpayHashSecret: String { AppSecrets.string("VNPayHashSecret") ?? "" }
    static var vnpayPaymentUrl: String {
        AppSecrets.string("VNPayPaymentUrl", default: "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html")
    }

    static var isMoMoConfigured: Bool {
        !momoPartnerCode.isEmpty && !momoAccessKey.isEmpty && !momoSecretKey.isEmpty && !momoIpnUrl.isEmpty
    }

    static var isVNPayConfigured: Bool {
        !vnpayTmnCode.isEmpty && !vnpayHashSecret.isEmpty
    }
}
