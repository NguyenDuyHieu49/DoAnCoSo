//
//  ImageExtension.swift
//  Hotelia
//
//  Created by Macbook Pro on 19/5/26.
//
import UIKit

extension UIImage {
    func normalizedImage() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalized
    }
}
