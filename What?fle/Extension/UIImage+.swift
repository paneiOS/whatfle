//
//  UIImage+.swift
//  What?fle
//
//  Created by 이정환 on 5/14/24.
//

import UIKit

extension UIImage {
    func resizedImageWithinMegabytes(megabytes: Double = 10.0) -> Data? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else { return nil }

        let maxBytes = megabytes * 1024 * 1024
        if Double(imageData.count) < maxBytes {
            return imageData
        }

        var resizeRatio = CGFloat(maxBytes / Double(imageData.count))
        var compressedData = imageData

        while Double(compressedData.count) > maxBytes && resizeRatio > 0 {
            guard let resizedImageData = self.jpegData(compressionQuality: resizeRatio) else { break }
            compressedData = resizedImageData
            resizeRatio -= 0.1
        }

        return compressedData
    }
}
