//
//  GradientView.swift
//  What?fle
//
//  Created by 이정환 on 8/4/24.
//

import UIKit

final class GradientView: UIView {
    enum GradientDirection {
        case topToBottom
        case leftToRight
        case topLeftToBottomRight
        case topRightToBottomLeft
    }

    private var gradientLayer: CAGradientLayer?

    init(colors: [UIColor], direction: GradientDirection = .topToBottom) {
        super.init(frame: .zero)
        applyGradient(colors: colors, direction: direction)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyGradient(colors: [.clear, .clear], direction: .topToBottom)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }

    func applyGradient(colors: [UIColor], direction: GradientDirection) {
        gradientLayer?.removeFromSuperlayer()

        let newGradientLayer = CAGradientLayer()
        newGradientLayer.colors = colors.map { $0.cgColor }

        switch direction {
        case .topToBottom:
            newGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            newGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        case .leftToRight:
            newGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            newGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .topLeftToBottomRight:
            newGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            newGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        case .topRightToBottomLeft:
            newGradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            newGradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        }

        newGradientLayer.frame = bounds
        layer.insertSublayer(newGradientLayer, at: 0)
        gradientLayer = newGradientLayer
    }
}
