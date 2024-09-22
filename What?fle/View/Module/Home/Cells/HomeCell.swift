//
//  HomeCell.swift
//  What?fle
//
//  Created by 이정환 on 9/10/24.
//

import UIKit

import RxCocoa
import RxSwift

protocol HomeCellDelegate: AnyObject {
    func didTapFavoriteButton(id: Int, isFavorite: Bool)
}

final class HomeCell: UICollectionViewCell {
    private enum Constants {
        static let imageWidth: CGFloat = (UIApplication.shared.width - 32) / 2
    }

    static let reuseIdentifier = "HomeCell"

    weak var delegate: HomeCellDelegate?

    private let totalView: UIView = .init()

    private lazy var tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 6
        let collectionView = UICollectionView(
            frame: .init(x: 0, y: 0, width: UIApplication.shared.width - 32, height: 32
            ),
            collectionViewLayout: layout
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BasicTagCell.self, forCellWithReuseIdentifier: BasicTagCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private let headerView: UIView = .init()
    private let titleLabel: UILabel = .init()
    private let subtitleLabel: UILabel = .init()
    private let favoriteButton: FavoriteButton = .init()

    private let totalImageView: UIView = .init()
    private let topLeftImageView: ImageView = .init()
    private let topRightImageView: ImageView = .init()
    private let bottomLeftImageView: ImageView = .init()
    private let bottomRightImageView: ImageView = .init()

    private let profileView: UIView = .init()
    private let profileImageView: ImageView = {
        let imageView: ImageView = .init()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lineExtralight.cgColor
        return imageView
    }()
    private let userName: UILabel = .init()
    private let bottomLineView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .lineExtralight
        return view
    }()

    private var tags: [String] = [] {
        didSet {
            self.tagCollectionView.reloadData()
        }
    }

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
        self.setupActionBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
        self.setupActionBinding()
    }
}

extension HomeCell {
    private func setupUI() {
        contentView.addSubviews(self.totalView, self.bottomLineView)
        self.totalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(19)
            $0.leading.trailing.equalToSuperview()
        }

        self.totalView.addSubviews(self.tagCollectionView, self.headerView, self.totalImageView, self.profileView)
        self.tagCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }

        self.headerView.addSubviews(self.titleLabel, self.subtitleLabel, self.favoriteButton)

        self.headerView.snp.makeConstraints {
            $0.top.equalTo(self.tagCollectionView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.equalTo(self.favoriteButton.snp.leading)
        }
        self.subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            $0.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(self.favoriteButton.snp.leading)
        }
        self.favoriteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(32)
        }

        self.totalImageView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.imageWidth * 2)
        }

        self.totalImageView.addSubviews(
            self.topLeftImageView,
            self.topRightImageView,
            self.bottomLeftImageView,
            self.bottomRightImageView
        )

        self.topLeftImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(Constants.imageWidth)
        }
        self.topRightImageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(Constants.imageWidth)
        }
        self.bottomLeftImageView.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview()
            $0.size.equalTo(Constants.imageWidth)
        }
        self.bottomRightImageView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
            $0.size.equalTo(Constants.imageWidth)
        }

        self.profileView.addSubviews(self.profileImageView, self.userName)
        self.profileView.snp.makeConstraints {
            $0.top.equalTo(self.totalImageView.snp.bottom).offset(8)
            $0.trailing.bottom.equalToSuperview()
        }
        self.profileImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.size.equalTo(24)
        }
        self.userName.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(8)
        }

        self.bottomLineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func drawCell(model: HomeDataModel.Content) {
        self.tag = model.collection.id

        self.tags = model.collection.hashtags.map { $0.hashtagName }

        self.favoriteButton.isSelected = model.collection.isFavoriate

        self.titleLabel.attributedText = .makeAttributedString(
            text: model.collection.title,
            font: .title20XBD,
            textColor: .textDefault,
            lineHeight: 28
        )

        self.subtitleLabel.attributedText = .makeAttributedString(
            text: model.collection.description,
            font: .caption13MD,
            textColor: .textLight,
            lineHeight: 20
        )

        let imageViews = [
            self.topLeftImageView,
            self.topRightImageView,
            self.bottomLeftImageView,
            self.bottomRightImageView
        ]
        for (idx, imageURL) in (model.collection.places.compactMap { $0.imageURLs?.first }).enumerated() {
            guard idx < 5 else { return }
            imageViews[idx].loadImage(from: imageURL)
        }

        self.profileImageView.loadImage(from: model.account.imageURL)
        self.userName.attributedText = .makeAttributedString(
            text: model.account.nickname,
            font: .body14MD,
            textColor: .textExtralight,
            lineHeight: 20
        )
    }

    private func setupActionBinding() {
        self.favoriteButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.didTapFavoriteButton(id: self.tag, isFavorite: self.favoriteButton.isSelected)
            })
            .disposed(by: disposeBag)
    }
}

extension HomeCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasicTagCell.reuseIdentifier, for: indexPath) as? BasicTagCell,
              let tag = self.tags[safe: indexPath.row] else { return UICollectionViewCell() }
        cell.drawCell(hashtagName: tag)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let hashtagName = tags[safe: indexPath.item] else { return .zero }
        let attributedString: NSAttributedString = NSAttributedString(
            string: hashtagName,
            attributes: [
                .font: UIFont.body14MD
            ]
        )
        let width = attributedString.width(containerHeight: 32) + 24
        return CGSize(width: width, height: 32)
    }
}
