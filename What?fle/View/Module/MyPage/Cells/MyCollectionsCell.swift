//
//  MyCollectionsCell.swift
//  What?fle
//
//  Created by 이정환 on 11/6/24.
//

import UIKit

protocol MyCollectionsCellDelegate: AnyObject {
    func showDetailCollection(id: Int)
}

final class MyCollectionsCell: UICollectionViewCell {
    static let reuseIdentifier = "MyCollectionsCell"
    weak var delegate: MyCollectionsCellDelegate?

    private let headerView: MyPageHeaderView = .init(title: "나의 컬렉션 목록")

    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 16, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(MyCollectionSubCell.self, forCellWithReuseIdentifier: MyCollectionSubCell.reuseIdentifier)
        return collectionView
    }()

    private var model: [HomeDataModel.Collection] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
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

    func drawCell(model: [HomeDataModel.Collection]) {
        self.model = model
    }
}

extension MyCollectionsCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 120, height: 146)
    }
}

extension MyCollectionsCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionSubCell.reuseIdentifier, for: indexPath) as? MyCollectionSubCell,
            let collection = model[safe: indexPath.item] else { return emptyCell }
        cell.drawCell(collection: collection)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = self.model[safe: indexPath.item]?.id else { return }
        self.delegate?.showDetailCollection(id: id)
    }
}

final class MyCollectionSubCell: UICollectionViewCell {
    static let reuseIdentifier = "MyCollectionSubCell"

    private let imageView: ImageView = {
        let view: ImageView = .init()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()

    private let label: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        self.contentView.addSubviews(self.imageView, self.label)
        self.imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.size.equalTo(120)
        }

        self.label.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    func drawCell(collection: HomeDataModel.Collection) {
        self.label.attributedText = .makeAttributedString(
            text: collection.title,
            font: .caption12RG,
            textColor: .textLight,
            lineHeight: 20
        )
        self.imageView.loadImage(from: collection.places.first?.imageURLs?.first)
    }
}
