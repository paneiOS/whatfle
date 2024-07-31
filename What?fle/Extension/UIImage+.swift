//
//  UIImage+.swift
//  What?fle
//
//  Created by 이정환 on 5/14/24.
//

import UIKit

extension UIImage {
    func resizedImageWithinKilobytes(kilobytes: Double = 10.0) -> Data? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else { return nil }

        let maxBytes = kilobytes * 1024
//        print("Original Image Size: \(Double(imageData.count) / 1024 / 1024) MB")

        if Double(imageData.count) < maxBytes {
//            print("No resizing needed as the original image is within the limit.")
            return imageData
        }

        var resizeRatio = CGFloat(maxBytes / Double(imageData.count))
        var compressedData = imageData

        while Double(compressedData.count) > maxBytes && resizeRatio > 0 {
            guard let resizedImageData = self.jpegData(compressionQuality: resizeRatio) else { break }
            compressedData = resizedImageData
            resizeRatio -= 0.1
        }
//        print("Resized Image Size: \(Double(compressedData.count) / 1024 / 1024) MB")
        return compressedData
    }
}
