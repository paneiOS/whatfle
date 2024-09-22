//
//  SelectLocationResultCell.swift
//  What?fle
//
//  Created by 이정환 on 4/7/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class SelectLocationResultCell: UICollectionViewCell {
    static let reuseIdentifier = "SelectLocationResultCell"

    private let imageView: ImageView = {
        let imageView: ImageView = .init()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.imageView.snp.width)
        }

        contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func drawCell(model: PlaceRegistration) {
        self.titleLabel.attributedText = .makeAttributedString(
            text: model.placeName,
            font: .caption12RG,
            textColor: .textLight,
            lineHeight: 20,
            alignment: .center
        )

        if let urlStr = model.imageURLs.first {
            self.imageView.loadImage(from: urlStr)
        }
    }
}
