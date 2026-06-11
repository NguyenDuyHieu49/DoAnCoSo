//
//  CloudinaryService.swift
//  Hotelia
//
//  Created by Macbook Pro on 19/5/26.
//
import UIKit
import Foundation

struct CloudinaryService {

    private static var cloudName: String { AppSecrets.string("CloudinaryCloudName") ?? "" }
    private static var uploadPreset: String { AppSecrets.string("CloudinaryUploadPreset") ?? "" }

    static func uploadImage(_ image: UIImage) async throws -> String {
        guard !cloudName.isEmpty, !uploadPreset.isEmpty else {
            throw NSError(domain: "Cloudinary", code: -3,
                         userInfo: [NSLocalizedDescriptionKey: "Missing Cloudinary credentials in Secrets.plist"])
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "Cloudinary", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: String(localized: "image_convert_failed")])
        }
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        // file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let secureUrl = json["secure_url"] as? String else {
            let raw = String(data: responseData, encoding: .utf8) ?? "unknown"
            throw NSError(domain: "Cloudinary", code: -2,
                         userInfo: [NSLocalizedDescriptionKey: String(localized: "upload_failed \(raw)")])
        }
        
        print("[Cloudinary] Upload OK:", secureUrl)
        return secureUrl
    }
    
    static func uploadImages(_ images: [UIImage]) async throws -> [String] {
        var urls: [String] = []
        for (index, image) in images.enumerated() {
            print("[Cloudinary] Uploading image \(index)...")
            let url = try await uploadImage(image)
            urls.append(url)
        }
        return urls
    }
}
