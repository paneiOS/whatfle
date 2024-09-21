//
//  TriangleView.swift
//  What?fle
//
//  Created by 이정환 on 8/12/24.
//

import UIKit

final class TriangleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.beginPath()
        context.move(to: CGPoint(x: rect.width / 2, y: 0))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height))
        context.addLine(to: CGPoint(x: 0, y: rect.height))
        context.closePath()

        context.setFillColor(UIColor.Core.background.cgColor)
        context.fillPath()
    }
}
