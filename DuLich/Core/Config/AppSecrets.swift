import Foundation

enum AppSecrets {
    private static let plist: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            print("[AppSecrets] Missing Secrets.plist — copy Secrets.plist.example to Secrets.plist and fill in your keys.")
            return [:]
        }
        return dict
    }()

    private static let environmentAliases: [String: [String]] = [
        "PaymentReturnScheme": ["PAYMENT_RETURN_SCHEME"],
        "MoMoPartnerCode": ["MOMO_PARTNER_CODE"],
        "MoMoAccessKey": ["MOMO_ACCESS_KEY"],
        "MoMoSecretKey": ["MOMO_SECRET_KEY"],
        "MoMoEndpoint": ["MOMO_ENDPOINT"],
        "MoMoIpnUrl": ["MOMO_IPN_URL"],
        "VNPayTmnCode": ["VNPAY_TMN_CODE"],
        "VNPayHashSecret": ["VNPAY_HASH_SECRET"],
        "VNPayPaymentUrl": ["VNPAY_PAYMENT_URL"],
        "OpenWeatherAPIKey": ["OPEN_WEATHER_API_KEY"],
        "CloudinaryCloudName": ["CLOUDINARY_CLOUD_NAME"],
        "CloudinaryUploadPreset": ["CLOUDINARY_UPLOAD_PRESET"],
        "AdminSecretPassword": ["ADMIN_SECRET_PASSWORD"]
    ]

    static func string(_ key: String) -> String? {
        for envKey in environmentKeys(for: key) {
            if let envValue = ProcessInfo.processInfo.environment[envKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
               !envValue.isEmpty {
                return envValue
            }
        }
        if let value = plist[key] as? String {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, !trimmed.hasPrefix("YOUR_") {
                return trimmed
            }
        }
        return nil
    }

    static func string(_ key: String, default defaultValue: String) -> String {
        string(key) ?? defaultValue
    }

    private static func environmentKeys(for key: String) -> [String] {
        var keys = [key]
        if let aliases = environmentAliases[key] {
            keys.append(contentsOf: aliases)
        }
        return keys
    }
}
