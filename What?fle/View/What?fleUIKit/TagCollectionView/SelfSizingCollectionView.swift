//
//  SelfSizingCollectionView.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import UIKit

class SelfSizingCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        invalidateIntrinsicContentSize()
    }
}
