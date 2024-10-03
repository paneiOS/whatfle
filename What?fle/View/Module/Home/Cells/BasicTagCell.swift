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

    var view: UIView {
        return self.contentView
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        return CGSize(width: labelSize.width, height: labelSize.height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    private func setupUI() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.addSubview(label)
        self.label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }

    func drawLabel(tag: NSAttributedString) {
        self.label.attributedText = tag
    }
}
