import Foundation

final class VNPayGateway {
    static let shared = VNPayGateway()
    private init() {}

    func buildPaymentURL(amount: Int, orderInfo: String, txnRef: String) throws -> URL {
        guard PaymentConfig.isVNPayConfigured else {
            print("[VNPayGateway] Missing VNPay credentials in Secrets.plist")
            throw PaymentError.processingFailed
        }
        guard amount >= 5_000 else {
            throw PaymentError.invalidAmount(minimum: 5_000)
        }

        let createDate = Self.vnpDateFormatter.string(from: Date())
        let expireDate = Self.vnpDateFormatter.string(from: Date().addingTimeInterval(24 * 60 * 60))
        let sanitizedInfo = PaymentText.sanitizeOrderInfo(orderInfo)

        var params: [String: String] = [
            "vnp_Version": "2.1.0",
            "vnp_Command": "pay",
            "vnp_TmnCode": PaymentConfig.vnpayTmnCode,
            "vnp_Amount": String(amount * 100),
            "vnp_CurrCode": "VND",
            "vnp_TxnRef": txnRef,
            "vnp_OrderInfo": sanitizedInfo,
            "vnp_OrderType": "other",
            "vnp_Locale": "vn",
            "vnp_ReturnUrl": PaymentConfig.vnpayReturnURL,
            "vnp_IpAddr": "127.0.0.1",
            "vnp_CreateDate": createDate,
            "vnp_ExpireDate": expireDate
        ]

        let sortedKeys = params.keys.sorted()
        let signData = sortedKeys
            .map { key in
                let value = params[key] ?? ""
                let encoded = Self.vnpEncode(value).replacingOccurrences(of: "%20", with: "+")
                return "\(key)=\(encoded)"
            }
            .joined(separator: "&")

        let secureHash = PaymentCrypto.hmacSHA512Hex(key: PaymentConfig.vnpayHashSecret, message: signData)
        let query = signData + "&vnp_SecureHash=\(secureHash)"
        guard let url = URL(string: PaymentConfig.vnpayPaymentUrl + "?" + query) else {
            throw PaymentError.processingFailed
        }
        return url
    }

    func parseReturnURL(_ url: URL) throws -> PaymentCheckoutResult {
        let params = url.paymentQueryParameters
        guard let receivedHash = params["vnp_SecureHash"] else {
            throw PaymentError.processingFailed
        }

        var verifyParams = params
        verifyParams.removeValue(forKey: "vnp_SecureHash")
        verifyParams.removeValue(forKey: "vnp_SecureHashType")

        let signData = verifyParams.keys.sorted()
            .map { key in
                let value = verifyParams[key] ?? ""
                let encoded = Self.vnpEncode(value).replacingOccurrences(of: "%20", with: "+")
                return "\(key)=\(encoded)"
            }
            .joined(separator: "&")

        let expectedHash = PaymentCrypto.hmacSHA512Hex(key: PaymentConfig.vnpayHashSecret, message: signData)
        guard expectedHash.caseInsensitiveCompare(receivedHash) == .orderedSame else {
            throw PaymentError.gatewayRejected(message: String(localized: "vnpay_invalid_signature"))
        }

        let responseCode = params["vnp_ResponseCode"] ?? ""
        guard responseCode == "00" else {
            throw PaymentError.gatewayRejected(message: Self.vnpayMessage(for: responseCode))
        }

        let transactionId = params["vnp_TransactionNo"] ?? params["vnp_TxnRef"] ?? UUID().uuidString
        let orderId = params["vnp_TxnRef"] ?? transactionId
        return PaymentCheckoutResult(transactionId: transactionId, orderId: orderId, method: .vnpay)
    }

    private static let vnpDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 7 * 3600)
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter
    }()

    private static func vnpEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }

    private static func vnpayMessage(for code: String) -> String {
        switch code {
        case "24": return String(localized: "vnpay_cancelled")
        case "07": return String(localized: "vnpay_suspicious")
        case "09": return String(localized: "vnpay_no_internet_banking")
        case "10": return String(localized: "vnpay_card_auth_failed")
        case "11": return String(localized: "vnpay_expired")
        case "12": return String(localized: "vnpay_card_locked")
        case "13": return String(localized: "vnpay_wrong_otp")
        case "51": return String(localized: "vnpay_insufficient")
        case "65": return String(localized: "vnpay_daily_limit")
        default: return String(localized: "vnpay_failed_code \(code)")
        }
    }
}
