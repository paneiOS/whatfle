//
//  SimpleImageCell.swift
//  What?fle
//
//  Created by 이정환 on 9/17/24.
//

import UIKit

import SnapKit

final class SimpleImageCell: UICollectionViewCell {
    static let reuseIdentifier = "SimpleImageCell"

    private let imageView: ImageView = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
    }

    func setupUI() {
        contentView.layer.borderColor = UIColor.lineExtralight.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
        contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func drawCell(imageURL: String) {
        self.imageView.loadImage(from: imageURL)
    }
}
