//
//  SearchResultViewCell.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import UIKit

import SnapKit

final class SearchResultViewCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchResultViewCell"

    private let imageView: ImageView = {
        let imageView: ImageView = .init()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 4
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lineExtralight.cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let labelView: UIView = .init()

    private let titleLabel: UILabel = .init()

    private let subtitleLabel: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    private func setupUI() {
        contentView.addSubviews(self.imageView, self.labelView)
        self.imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(16)
            $0.size.equalTo(64)
        }
        self.labelView.snp.makeConstraints {
            $0.leading.equalTo(self.imageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(26)
        }
        self.labelView.addSubviews(self.titleLabel, self.subtitleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
        }
        self.subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func drawCell(model: TotalSearchData.CollectionContent.Collection) {
        self.titleLabel.attributedText = .makeAttributedString(
            text: model.title,
            font: .body14SB,
            textColor: .textDefault,
            lineHeight: 20
        )
        self.subtitleLabel.attributedText = .makeAttributedString(
            text: model.description,
            font: .caption12RG,
            textColor: .textExtralight,
            lineHeight: 20
        )
        if let urlStr = model.imageURLs?.first {
            self.imageView.loadImage(from: urlStr)
        }
    }
}
