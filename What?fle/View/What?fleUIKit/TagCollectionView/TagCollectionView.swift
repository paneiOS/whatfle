//
//  TagCollectionView.swift
//  What?fle
//
//  Created by JeongHwan Lee on 7/6/24.
//

import UIKit

final class TagCollectionView: SelfSizingCollectionView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    init(scrollDirection: UICollectionView.ScrollDirection = .vertical) {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        super.init(frame: .zero, collectionViewLayout: layout)

        self.contentInset = .zero
        self.backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        invalidateIntrinsicContentSize()
    }

    func setScrollDirection(_ direction: UICollectionView.ScrollDirection) {
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = direction
            self.collectionViewLayout.invalidateLayout()
        }
    }
}
