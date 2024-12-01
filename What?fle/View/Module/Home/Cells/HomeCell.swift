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
    func didTapFavoriteCollection(id: Int, isFavorite: Bool)
}

final class HomeCell: UICollectionViewCell {
    private enum Constants {
        static let imageWidth: CGFloat = floor((UIApplication.shared.width - 32) / 2)
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
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(BasicTagCell.self, forCellWithReuseIdentifier: BasicTagCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private let headerView: UIView = .init()
    private let titleLabel: UILabel = .init()
    private let subtitleLabel: UILabel = .init()
    private let favoriteButton: FavoriteButton = .init()

    private let totalImageView: UIView = .init()

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

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.attributedText = nil
        self.subtitleLabel.attributedText = nil
        self.favoriteButton.isSelected = false
        self.userName.attributedText = nil
    }
}

extension HomeCell {
    private func setupUI() {
        contentView.addSubviews(self.totalView, self.bottomLineView)
        self.totalView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(19)
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
        self.favoriteButton.isSelected = model.collection.isFavorite
        self.titleLabel.attributedText = .makeAttributedString(
            text: model.collection.title + model.type.rawValue,
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
        let imageURLs = model.collection.places.compactMap { $0.imageURLs?.first }
        self.makeImageGrid(with: imageURLs, type: model.type)
        self.userName.attributedText = .makeAttributedString(
            text: model.account.nickname,
            font: .body14MD,
            textColor: .textExtralight,
            lineHeight: 20
        )
    }

    func drawCell(model: HomeDataModel.Collection) {
        self.tag = model.id
        self.tags = model.hashtags.map { $0.hashtagName }
        self.favoriteButton.isSelected = model.isFavorite
        self.titleLabel.attributedText = .makeAttributedString(
            text: model.title,
            font: .title20XBD,
            textColor: .textDefault,
            lineHeight: 28
        )
        self.subtitleLabel.attributedText = .makeAttributedString(
            text: model.description,
            font: .caption13MD,
            textColor: .textLight,
            lineHeight: 20
        )
        let imageURLs = model.places.compactMap { $0.imageURLs?.first }
        self.makeImageGrid(with: imageURLs, type: .type1)
        if let userInfo = SessionManager.shared.loadUserInfo() {
            self.profileImageView.loadImage(from: userInfo.profileImagePath)
            self.userName.attributedText = .makeAttributedString(
                text: userInfo.nickname ?? "",
                font: .body14MD,
                textColor: .textExtralight,
                lineHeight: 20
            )
        }
    }

    private func setupActionBinding() {
        self.favoriteButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.didTapFavoriteCollection(id: self.tag, isFavorite: self.favoriteButton.isSelected)
            })
            .disposed(by: disposeBag)
    }

    private func makeImageGrid(with imageURLs: [String], type: ImageGridType) {
        self.totalImageView.subviews.forEach { $0.removeFromSuperview() }
        if imageURLs.isEmpty {
            self.addSingleImage(image: .placehold ,height: type.imageHeight)
            return
        }
        if imageURLs.count < 4, let imageURL = imageURLs.first {
            self.addSingleImage(imageURL: imageURL, height: type.imageHeight)
            return
        }
        let imageViews = createImageViews(from: imageURLs)
           switch type {
           case .type1:
               applyTypeDoubleLayout(with: imageViews)
               updateHeight(Constants.imageWidth * 2)
           case .type2:
               applyTypeDoubleLayout(with: imageViews, isRadious: true)
               updateHeight(Constants.imageWidth * 2)
           case .type3:
               applyType3Layout(with: imageViews)
               updateHeight(120)
           case .type4:
               addSingleImage(imageURL: imageURLs.first, height: type.imageHeight)
           default:
               addSingleImage(imageURL: imageURLs.first, height: Constants.imageWidth * 2)
           }
    }

    private func applyTypeDoubleLayout(with imageViews: [ImageView], isRadious: Bool = false) {
        guard imageViews.count >= 4 else { return }
        let size = Constants.imageWidth
        imageViews[0...3].enumerated().forEach { index, imageView in
            totalImageView.addSubview(imageView)
            if isRadious {
                imageView.layer.cornerRadius = size / 2
                imageView.clipsToBounds = true
            }
            imageView.snp.makeConstraints {
                $0.size.equalTo(size)
                switch index {
                case 0: $0.top.leading.equalToSuperview()
                case 1: $0.top.trailing.equalToSuperview()
                case 2: $0.bottom.leading.equalToSuperview()
                case 3: $0.bottom.trailing.equalToSuperview()
                default: break
                }
            }
        }
    }

    private func applyType3Layout(with imageViews: [ImageView]) {
        let width = self.totalImageView.bounds.width / 4
        for (index, imageView) in imageViews.enumerated() {
            self.totalImageView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.height.equalTo(ImageGridType.type3.imageHeight)
                $0.width.equalToSuperview().dividedBy(4)
                $0.leading.equalTo(CGFloat(index) * width)
            }
        }
    }

    private func addSingleImage(imageURL: String? = nil, image: UIImage? = nil, height: CGFloat) {
        let imageView = ImageView()
        if let imageURL = imageURL {
            imageView.loadImage(from: imageURL, placeholder: .placehold)
        } else if let image = image {
            imageView.image = image
        }
        totalImageView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        updateHeight(height)
    }

    private func updateHeight(_ height: CGFloat) {
        self.totalImageView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }

    private func createImageViews(from imageURLs: [String]) -> [ImageView] {
        return imageURLs.map {
            let imageView = ImageView()
            imageView.loadImage(from: $0, placeholder: .placehold)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }
    }
}

extension HomeCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasicTagCell.reuseIdentifier, for: indexPath) as? BasicTagCell,
              let tag = self.tags[safe: indexPath.row] else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath)
        }
        cell.view.backgroundColor = .Core.p100
        cell.drawLabel(tag: .makeAttributedString(
            text: tag,
            font: .body14MD,
            textColor: .Core.p400,
            lineHeight: 20
        ))
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
