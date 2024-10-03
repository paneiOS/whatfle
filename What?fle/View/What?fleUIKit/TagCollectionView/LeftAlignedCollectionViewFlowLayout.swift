//
//  LeftAlignedCollectionViewFlowLayout.swift
//  What?fle
//
//  Created by JeongHwan Lee on 7/7/24.
//

import UIKit

final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        if scrollDirection == .vertical {
            var leftMargin: CGFloat = sectionInset.left
            var maxY: CGFloat = -1.0

            attributes?.forEach { layoutAttribute in
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, layoutAttribute.frame.origin.y)
            }
        } else if scrollDirection == .horizontal {
            var topMargin: CGFloat = sectionInset.top
            var maxX: CGFloat = -1.0

            attributes?.forEach { layoutAttribute in
                if layoutAttribute.frame.origin.x >= maxX {
                    topMargin = sectionInset.top
                }
                layoutAttribute.frame.origin.y = topMargin
                topMargin += layoutAttribute.frame.height + minimumLineSpacing
                maxX = max(layoutAttribute.frame.maxX, layoutAttribute.frame.origin.x)
            }
        }
        return attributes
    }
}
