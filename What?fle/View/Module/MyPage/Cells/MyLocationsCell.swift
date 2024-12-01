//
//  MyLocationsCell.swift
//  What?fle
//
//  Created by 이정환 on 11/6/24.
//

import UIKit

import RxSwift

protocol MyLocationsCellDelegate: AnyObject {
    func showDetailLocation(model: HomeDataModel.Collection.Place)
    func showMyLocations()
    func didTapFavoriteButton(id: Int, isFavorite: Bool)
}

final class MyLocationsCell: UICollectionViewCell {
    private enum Constants {
        static let cellWidth: CGFloat = UIApplication.shared.width - 32
    }

    weak var delegate: MyLocationsCellDelegate?
    static let reuseIdentifier = "MyLocationsCell"

    private let headerView: MyPageHeaderView = .init(title: "최근 체크인 장소")

    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 16, right: 16)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(MyLocationSubCell.self, forCellWithReuseIdentifier: MyLocationSubCell.reuseIdentifier)
        return collectionView
    }()

    private var model: [HomeDataModel.Collection.Place] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActionBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActionBinding()
    }

    private func setupUI() {
        self.contentView.addSubviews(self.headerView, self.collectionView)
        self.headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func drawCell(model: [HomeDataModel.Collection.Place]) {
        self.model = model
    }

    func setupActionBinding() {
        self.headerView.moreButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.showMyLocations()
            })
            .disposed(by: disposeBag)
    }
}

extension MyLocationsCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: Constants.cellWidth, height: 88)
    }
}

extension MyLocationsCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyLocationSubCell.reuseIdentifier, for: indexPath) as? MyLocationSubCell,
            let place = model[safe: indexPath.item] else { return emptyCell }
        cell.drawCell(place: place, isFavorite: false)
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.model[safe: indexPath.item] else { return }
        self.delegate?.showDetailLocation(model: model)
    }
}

extension MyLocationsCell: MyLocationSubCellDelegate {
    func didTapFavoriteLocation(id: Int, isFavorite: Bool) {
        self.delegate?.didTapFavoriteButton(id: id, isFavorite: isFavorite)
    }
}

protocol MyLocationSubCellDelegate: AnyObject {
    func didTapFavoriteLocation(id: Int, isFavorite: Bool)
}

final class MyLocationSubCell: UICollectionViewCell {
    static let reuseIdentifier = "MyLocationSubCell"

    private let imageView: ImageView = {
        let view: ImageView = .init()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    private let subView: UIView = .init()
    private let label: UILabel = .init()
    private let subLabel: UILabel = .init()
    private let favoriteButton: FavoriteButton = {
        let button: FavoriteButton = .init()
        button.isHidden = true
        return button
    }()
    private let disposeBag = DisposeBag()

    weak var delegate: MyLocationSubCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActionBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActionBinding()
    }

    private func setupUI() {
        self.contentView.addSubviews(self.imageView, self.subView, self.favoriteButton)
        self.imageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(12)
            $0.size.equalTo(64)
        }

        self.subView.addSubviews(self.label, self.subLabel)
        self.label.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.equalTo(self.favoriteButton.snp.leading)
        }
        self.subLabel.snp.makeConstraints {
            $0.top.equalTo(self.label.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.subView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.imageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(12)
        }
        self.favoriteButton.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.size.equalTo(32)
        }
    }

    func drawCell(place: HomeDataModel.Collection.Place, isFavorite: Bool) {
        self.tag = place.id
        self.label.attributedText = .makeAttributedString(
            text: place.placeName,
            font: .body14XBD,
            textColor: .black,
            lineHeight: 20
        )
        self.subLabel.attributedText = .makeAttributedString(
            text: place.address,
            font: .caption12RG,
            textColor: .textExtralight,
            lineHeight: 20
        )
        self.imageView.loadImage(from: place.imageURLs?.first)
        self.favoriteButton.isHidden = !isFavorite
        self.favoriteButton.isSelected = isFavorite
    }

    private func setupActionBinding() {
        self.favoriteButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.didTapFavoriteLocation(id: self.tag, isFavorite: self.favoriteButton.isSelected)
            })
            .disposed(by: disposeBag)
    }
}
