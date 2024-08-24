//
//  UIStackView+.swift
//  What?fle
//
//  Created by 이정환 on 8/24/24.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { self.addArrangedSubview($0) }
    }
}
