//
//  UIImage+.swift
//  What?fle
//
//  Created by 이정환 on 5/14/24.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

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

    static func combine2x2(with images: [UIImage], width: CGFloat) -> UIImage? {
        guard images.count == 4 else { return nil }
        let size: CGSize = .init(width: width, height: width)
        let totalSize = CGSize(width: size.width, height: size.height)
        UIGraphicsBeginImageContext(totalSize)

        let width = size.width / 2
        let height = size.height / 2

        for (index, image) in images.enumerated() {
            let xPosition = (index % 2 == 0) ? 0 : width
            let yPosition = (index / 2 == 0) ? 0 : height
            image.draw(in: CGRect(x: xPosition, y: yPosition, width: width, height: height))
        }

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return combinedImage
    }

    static func combine1x4(with images: [UIImage], height: CGFloat) -> UIImage? {
        guard images.count == 4 else { return nil }

        let totalWidth = images.reduce(0) { $0 + $1.size.width }
        let totalSize = CGSize(width: totalWidth, height: height)
        UIGraphicsBeginImageContext(totalSize)

        var xOffset: CGFloat = 0

        for image in images {
            let aspectRatio = image.size.width / image.size.height
            let imageWidth = height * aspectRatio
            image.draw(in: CGRect(x: xOffset, y: 0, width: imageWidth, height: height))
            xOffset += imageWidth
        }

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return combinedImage
    }
}
