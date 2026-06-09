import Foundation

enum PaymentConfig {
    private static let plist: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            print("[PaymentConfig] Không đọc được Config.plist — dùng giá trị sandbox mặc định.")
            return [:]
        }
        return dict
    }()

    static var returnScheme: String {
        string("PaymentReturnScheme", default: "hotelia")
    }

    static var momoReturnURL: String { "\(returnScheme)://payment/momo" }
    static var vnpayReturnURL: String { "\(returnScheme)://payment/vnpay" }

    static var momoPartnerCode: String { string("MoMoPartnerCode", default: "MOMO") }
    static var momoAccessKey: String { string("MoMoAccessKey", default: "F8BBA842ECF85") }
    static var momoSecretKey: String {
        string("MoMoSecretKey", default: "K951B6PE2cbCzbiXgzQtxVN7OuTIm+0x/d57Qy6Si2DAsYyuIzFhz9LvImQoEmd")
    }
    static var momoEndpoint: String {
        string("MoMoEndpoint", default: "https://test-payment.momo.vn/v2/gateway/api/create")
    }
    static var momoIpnUrl: String {
        string("MoMoIpnUrl", default: "https://hotelia.app/payment/momo/ipn")
    }

    static var vnpayTmnCode: String { string("VNPayTmnCode", default: "2QXUI4J4") }
    static var vnpayHashSecret: String {
        string("VNPayHashSecret", default: "RAOEXHYVSDDIIENYWSLDIIZTANXUXZFJ")
    }
    static var vnpayPaymentUrl: String {
        string("VNPayPaymentUrl", default: "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html")
    }

    private static func string(_ key: String, default defaultValue: String) -> String {
        let value = plist[key] as? String
        return (value?.isEmpty == false) ? value! : defaultValue
    }
}
