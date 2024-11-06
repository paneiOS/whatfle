//
//  MyFavoriteCell.swift
//  What?fle
//
//  Created by 이정환 on 11/6/24.
//

import UIKit

import SnapKit

protocol MyFavoriteCellDelegate: AnyObject {
    func tapFavoriteLocation()
    func tapFavoriteCollection()
}

final class MyFavoriteCell: UICollectionViewCell {
    static let reuseIdentifier = "MyFavoriteCell"

    private enum Constants {
        static let buttonWidth: CGFloat = (UIApplication.shared.width - 32) / 2 - 2
    }

    private let subView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .Core.background
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var favoriteLocationButton: UIButton = {
        let button: UIButton = .init()
        var config: UIButton.Configuration = .plain()
        config.attributedTitle = .init(
            .makeAttributedString(
                text: "관심장소",
                font: .systemFont(ofSize: 12, weight: .regular),
                textColor: .black,
                lineHeight: 17
            )
        )
        config.image = .Icon.favoriteLocation.resized(to: .init(width: 40, height: 40))
        config.imagePlacement = .top
        config.imagePadding = 6
        button.configuration = config
        button.addTarget(self, action: #selector(tapFavoriteLocation), for: .touchUpInside)
        return button
    }()

    private lazy var favoriteCollectionButton: UIButton = {
        let button: UIButton = .init()
        var config: UIButton.Configuration = .plain()
        config.attributedTitle = .init(
            .makeAttributedString(
                text: "관심컬렉션",
                font: .systemFont(ofSize: 12, weight: .regular),
                textColor: .black,
                lineHeight: 17
            )
        )
        config.image = .Icon.favoriteCollection.resized(to: .init(width: 40, height: 40))
        config.imagePlacement = .top
        config.imagePadding = 6
        button.configuration = config
        button.addTarget(self, action: #selector(tapFavoriteCollection), for: .touchUpInside)
        return button
    }()

    private let interLineView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .lineLight
        return view
    }()

    weak var delegate: MyFavoriteCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
    }

    private func setupUI() {
        self.contentView.addSubviews(self.subView)
        self.subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.subView.addSubviews(self.favoriteLocationButton, self.interLineView, self.favoriteCollectionButton)
        self.favoriteLocationButton.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(Constants.buttonWidth)
        }
        self.interLineView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(2)
            $0.height.equalTo(48)
        }
        self.favoriteCollectionButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.width.equalTo(Constants.buttonWidth)
        }
    }

    @objc private func tapFavoriteLocation() {
        self.delegate?.tapFavoriteLocation()
    }

    @objc private func tapFavoriteCollection() {
        self.delegate?.tapFavoriteCollection()
    }
}
