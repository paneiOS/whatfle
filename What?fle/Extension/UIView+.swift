//
//  UIView+.swift
//  What?fle
//
//  Created by 이정환 on 3/6/24.
//

import UIKit

extension UIView {
    func addShadow(
        xPoint: CGFloat = 0,
        yPoint: CGFloat = 0,
        blur: CGFloat = 0,
        spread: CGFloat = 0,
        color: UIColor = .black,
        opacity: Float = 1
    ) {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: xPoint, height: yPoint)
        layer.shadowRadius = blur / 2.0
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor

        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dxPoint = -spread
            let rect = bounds.insetBy(dx: dxPoint, dy: dxPoint)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    func removeShadow() {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowPath = nil
    }

    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}
