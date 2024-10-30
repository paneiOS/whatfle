//
//  TopCell.swift
//  What?fle
//
//  Created by 이정환 on 9/17/24.
//

import UIKit

import SnapKit

protocol TopCellDelegate: AnyObject {
    func showDetailCell(id: Int)
}

final class TopCell: UICollectionViewCell {
    private enum Constants {
        static let imageSize: CGSize = .init(width: 131, height: 138)
    }

    static let reuseIdentifier = "TopCell"
    weak var delegate: TopCellDelegate?

    private let totalView: UIView = .init()
    private let headerView: UIView = .init()
    private let emphasisView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .init(hexCode: "#1EB433")
        view.layer.cornerRadius = 18
        return view
    }()
    private let emphasisLabel: UILabel = .init()
    private let emphasisSublabel: UILabel = .init()

    private let moreView: UIView = {
        let view: UIView = .init()
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "전체보기",
            font: .caption12RG,
            textColor: .textLight,
            lineHeight: 20
        )
        let button: UIImageView = .init(image: .Icon.arrowRightMd)
        view.addSubviews(label, button)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(2)
            $0.leading.equalToSuperview()
        }
        button.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(label.snp.trailing).offset(2)
            $0.size.equalTo(24)
        }
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        let collectionView = UICollectionView(
            frame: .init(origin: .zero, size: Constants.imageSize),
            collectionViewLayout: layout
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(SimpleImageCell.self, forCellWithReuseIdentifier: SimpleImageCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private var collections: [HomeDataModel.Collection] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
    }
}

extension TopCell {
    private func setupUI() {
        contentView.addSubviews(self.totalView)
        self.totalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(24)
            $0.leading.trailing.equalToSuperview()
        }
        self.totalView.addSubviews(self.headerView, self.collectionView)
        self.headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(36)
        }
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.headerView.addSubviews(self.emphasisView, self.emphasisSublabel, self.moreView)
        self.emphasisView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        self.emphasisView.addSubview(self.emphasisLabel)
        self.emphasisLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        self.emphasisSublabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(self.emphasisView.snp.trailing).offset(4)
        }
        self.moreView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.trailing.equalToSuperview()
        }
    }

    func drawCell(model: HomeDataModel.TopSection) {
        self.collections = model.collections
        self.emphasisLabel.attributedText = .makeAttributedString(
            text: model.hashtagName,
            font: .title16MD,
            textColor: .white,
            lineHeight: 24
        )
        self.emphasisSublabel.attributedText = .makeAttributedString(
            text: "를 모아봤어요",
            font: .body14RG,
            textColor: .textDefault,
            lineHeight: 20
        )
    }
}

extension TopCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collections.flatMap { $0.places }.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleImageCell.reuseIdentifier, for: indexPath) as? SimpleImageCell,
              let image = self.collections.flatMap({ $0.places })[safe: indexPath.item]?.imageURLs?.first else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath)
        }
        cell.drawCell(imageURL: image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 131, height: 138)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = self.collections[safe: indexPath.item]?.id else { return }
        self.delegate?.showDetailCell(id: id)
    }
}
