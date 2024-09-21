//
//  BasicTagCell.swift
//  What?fle
//
//  Created by 이정환 on 9/10/24.
//

import UIKit

import RxSwift
import SnapKit

final class BasicTagCell: UICollectionViewCell {
    static let reuseIdentifier = "BasicTagCell"

    private let label: UILabel = .init()

    private let disposeBag = DisposeBag()

    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        return CGSize(width: labelSize.width, height: labelSize.height)
    }

    func drawCell(hashtagName: String) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        label.attributedText = .makeAttributedString(
            text: hashtagName,
            font: .body14MD,
            textColor: .Core.p400,
            lineHeight: 20
        )
        contentView.backgroundColor = .Core.p100
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.Core.primary.cgColor
    }
}
