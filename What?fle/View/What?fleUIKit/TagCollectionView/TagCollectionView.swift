//
//  TagCollectionView.swift
//  What?fle
//
//  Created by JeongHwan Lee on 7/6/24.
//

import UIKit

final class TagCollectionView: UICollectionView {
    init() {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        super.init(frame: .zero, collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
