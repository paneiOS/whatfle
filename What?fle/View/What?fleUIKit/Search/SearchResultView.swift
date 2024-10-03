//
//  SearchResultView.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import UIKit

protocol SearchResultViewDelegate: AnyObject {
    var resultOfCollections: [TotalSearchData.CollectionContent.Collection] { get }
    var resultOfTags: [String] { get }
    func updateResultOfTags(_ tags: [String])
    func reloadData()
}

final class SearchResultView: UIView, SearchResultViewDelegate {

    // MARK: - UI Component

    private let tagHeaderView: UIView = .init()

    private let recentSearchLabel: UILabel = {
        let label: UILabel = .init()
        label.text = "관련 태그"
        label.font = .body14SB
        label.textColor = .textLight
        return label
    }()

    private lazy var tagCollectionView: TagCollectionView = {
        let view: TagCollectionView = .init()
        view.setScrollDirection(.horizontal)
        view.register(BasicTagCell.self, forCellWithReuseIdentifier: BasicTagCell.reuseIdentifier)
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    private lazy var resultCollectionView: UICollectionView = {
        let view: UICollectionView = .init()
        view.register(SearchResultViewCell.self, forCellWithReuseIdentifier: SearchResultViewCell.reuseIdentifier)
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        return view
    }()

    // MARK: - property

    var resultOfCollections: [TotalSearchData.CollectionContent.Collection] = []

    var resultOfTags: [String] = [] {
        didSet {
            self.tagCollectionView.reloadData()
        }
    }

    weak var delegate: SearchRecentViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
    }

    private func setupUI() {
        self.addSubviews(self.tagHeaderView, self.tagCollectionView)
        self.tagHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        self.tagHeaderView.addSubview(self.recentSearchLabel)
        self.recentSearchLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        self.tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.tagHeaderView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
    }
}

extension SearchResultView {
    func updateResultOfTags(_ tags: [String]) {
        self.resultOfTags = tags
    }

    func reloadData() {
        self.tagCollectionView.reloadData()
    }
}

extension SearchResultView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === self.tagCollectionView {
            return self.resultOfTags.count
        } else {
            return self.resultOfCollections.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === self.tagCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasicTagCell.reuseIdentifier, for: indexPath) as? BasicTagCell,
                  let tag = self.resultOfTags[safe: indexPath.item] else { return UICollectionViewCell() }
            cell.view.backgroundColor = .Core.background
            cell.drawLabel(tag: .makeAttributedString(
                text: tag,
                font: .body14MD,
                textColor: .textLight,
                lineHeight: 20
            ))
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultViewCell.reuseIdentifier, for: indexPath) as? SearchResultViewCell,
                  let model = self.resultOfCollections[safe: indexPath.item] else {
                return UICollectionViewCell()
            }
            cell.drawCell(model: model)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === self.tagCollectionView {
            guard let hashtagName = self.resultOfTags[safe: indexPath.item] else { return .zero }
            let attributedString: NSAttributedString = NSAttributedString(
                string: hashtagName,
                attributes: [
                    .font: UIFont.body14MD
                ]
            )
            let width = attributedString.width(containerHeight: 32) + 24
            return CGSize(width: width, height: 32)
        } else {
            return CGSize(width: UIApplication.shared.width - 32, height: 96)
        }
    }
}
