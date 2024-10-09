//
//  SearchButtonCell.swift
//  What?fle
//
//  Created by 이정환 on 10/1/24.
//

import UIKit

import SnapKit

class SearchButtonCell: UICollectionViewCell {
    private enum Constants {
        static let cellWidth: CGFloat = 64.0
    }

    static let reuseIdentifier = "SearchButtonCell"

    private let searchButton: UIView = {
        let view: UIView = .init()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lineDefault.cgColor
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "장소, 컬렉션 검색하기",
            font: .body14MD,
            textColor: .textExtralight,
            lineHeight: 20
        )
        let searchButtonImageView: UIImageView = .init(image: .Icon.search)
        searchButtonImageView.tintColor = .textExtralight
        view.addSubviews(label, searchButtonImageView)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(14)
        }
        searchButtonImageView.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    private func setupUI() {
        self.addSubview(self.searchButton)

        self.searchButton.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
}
