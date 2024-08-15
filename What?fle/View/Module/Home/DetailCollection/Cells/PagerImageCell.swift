//
//  PagerImageCell.swift
//  What?fle
//
//  Created by 이정환 on 8/14/24.
//

import Kingfisher
import UIKit

final class PagerImageCell: UICollectionViewCell {
    static let reuseIdentifier = "PagerImageCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
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
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func drawCell(with urlStr: String) {
        if let url = URL(string: urlStr) {
            imageView.kf.setImage(with: url, placeholder: UIImage.placehold)
        }
    }
}
