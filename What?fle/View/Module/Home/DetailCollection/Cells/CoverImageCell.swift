//
//  CoverImageCell.swift
//  What?fle
//
//  Created by 이정환 on 8/8/24.
//

import UIKit

import Kingfisher

final class CoverImageCell: UICollectionViewCell {
    static let reuseIdentifier = "CoverImageCell"

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func drawCell(urlStr: String) {
        self.coverImageView.kf.setImage(with: URL(string: urlStr), placeholder: UIImage.placehold)
    }
}
