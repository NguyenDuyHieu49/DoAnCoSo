import Foundation
import UIKit

struct MoMoCreateResponse: Decodable {
    let resultCode: Int?
    let errorCode: Int?
    let message: String?
    let payUrl: String?
    let deeplink: String?
    let orderId: String?
    let requestId: String?

    var isSuccess: Bool { (resultCode ?? errorCode ?? -1) == 0 }
}

final class MoMoGateway {
    static let shared = MoMoGateway()
    private init() {}

    func createPayment(amount: Int, orderInfo: String, orderId: String) async throws -> MoMoCreateResponse {
        guard amount >= 1_000 else {
            throw PaymentError.invalidAmount(minimum: 1_000)
        }

        let requestId = "\(orderId)-\(Int.random(in: 1000...9999))"
        let redirectUrl = PaymentConfig.momoReturnURL
        let ipnUrl = PaymentConfig.momoIpnUrl
        let extraData = ""
        let requestType = "captureWallet"
        let partnerCode = PaymentConfig.momoPartnerCode
        let accessKey = PaymentConfig.momoAccessKey
        let secretKey = PaymentConfig.momoSecretKey
        let safeOrderInfo = PaymentText.sanitizeOrderInfo(orderInfo)

        let rawSignature = [
            "accessKey=\(accessKey)",
            "amount=\(amount)",
            "extraData=\(extraData)",
            "ipnUrl=\(ipnUrl)",
            "orderId=\(orderId)",
            "orderInfo=\(safeOrderInfo)",
            "partnerCode=\(partnerCode)",
            "redirectUrl=\(redirectUrl)",
            "requestId=\(requestId)",
            "requestType=\(requestType)"
        ].joined(separator: "&")

        let signature = PaymentCrypto.hmacSHA256Hex(key: secretKey, message: rawSignature)

        let body: [String: Any] = [
            "partnerCode": partnerCode,
            "accessKey": accessKey,
            "partnerName": "Hotelia",
            "storeId": "HoteliaStore",
            "requestId": requestId,
            "amount": amount,
            "orderId": orderId,
            "orderInfo": safeOrderInfo,
            "redirectUrl": redirectUrl,
            "ipnUrl": ipnUrl,
            "lang": "vi",
            "extraData": extraData,
            "requestType": requestType,
            "signature": signature
        ]

        guard let url = URL(string: PaymentConfig.momoEndpoint) else {
            throw PaymentError.processingFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let bodyText = String(data: data, encoding: .utf8) ?? ""
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            print("[MoMoGateway] HTTP \( (response as? HTTPURLResponse)?.statusCode ?? -1):", bodyText)
            throw PaymentError.processingFailed
        }

        let decoded = try JSONDecoder().decode(MoMoCreateResponse.self, from: data)
        guard decoded.isSuccess, let payUrl = decoded.payUrl, !payUrl.isEmpty else {
            let code = decoded.resultCode ?? decoded.errorCode ?? -1
            let message = decoded.message ?? String(localized: "momo_rejected")
            print("[MoMoGateway] create failed (code \(code)):", message, "| body:", bodyText)
            throw PaymentError.gatewayRejected(message: "\(message) [\(code)]")
        }
        print("[MoMoGateway] create success, orderId:", orderId)
        return decoded
    }

    func parseReturnURL(_ url: URL) throws -> PaymentCheckoutResult {
        let params = url.paymentQueryParameters
        let resultCode = Int(params["resultCode"] ?? params["errorCode"] ?? "-1") ?? -1
        guard resultCode == 0 else {
            let message = params["message"] ?? params["localMessage"] ?? String(localized: "momo_failed")
            throw PaymentError.gatewayRejected(message: message)
        }

        let transactionId = params["transId"] ?? params["orderId"] ?? UUID().uuidString
        let orderId = params["orderId"] ?? transactionId
        return PaymentCheckoutResult(transactionId: transactionId, orderId: orderId, method: .momo)
    }

    @MainActor
    func openCheckout(response: MoMoCreateResponse) async throws -> PaymentCheckoutResult {
        if let payUrl = response.payUrl, let url = URL(string: payUrl) {
            return try await PaymentCheckoutCoordinator.shared.startWebCheckout(
                url: url,
                callbackScheme: PaymentConfig.returnScheme,
                method: .momo
            )
        }

        if let deeplink = response.deeplink,
           let deeplinkURL = URL(string: deeplink),
           UIApplication.shared.canOpenURL(deeplinkURL) {
            await UIApplication.shared.open(deeplinkURL)
            return try await PaymentCheckoutCoordinator.shared.waitForReturn(method: .momo, timeout: 300)
        }

        throw PaymentError.processingFailed
    }
}
