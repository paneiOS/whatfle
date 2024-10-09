//
//  SearchResultView.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import UIKit

final class SearchResultView: UIView {

    // MARK: - UI Component

    private let tagView: UIView = .init()

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

    private let resultView: UIView = .init()

    private let resultSearchLabel: UILabel = {
        let label: UILabel = .init()
        label.text = "컬렉션"
        label.font = .body14SB
        label.textColor = .textLight
        return label
    }()

    private let resultCountLabel: UILabel = .init()

    private lazy var resultCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(SearchResultViewCell.self, forCellWithReuseIdentifier: SearchResultViewCell.reuseIdentifier)
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        return view
    }()

    private let emptyView: UIView = {
        let view: UIView = .init()
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "최근 검색한 장소가 없습니다.",
            font: .body14MD,
            textColor: .textExtralight,
            lineHeight: 20
        )
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        return view
    }()

    // MARK: - property

    var resultData: (resultOfTags: [String], resultOfCollections: [TotalSearchData.CollectionContent.Collection])? {
        didSet {
            guard let resultData else { return }

            self.tagView.isHidden = resultData.resultOfTags.isEmpty
            self.tagCollectionView.reloadData()
            self.tagView.snp.updateConstraints {
                $0.height.equalTo(resultData.resultOfTags.isEmpty ? 0 : 92)
            }

            self.resultView.isHidden = resultData.resultOfCollections.isEmpty
            self.resultCollectionView.reloadData()

            if resultData.resultOfTags.isEmpty && resultData.resultOfCollections.isEmpty {
                self.addSubview(self.emptyView)
                self.emptyView.snp.makeConstraints {
                    $0.top.equalToSuperview().inset(72)
                    $0.leading.trailing.equalToSuperview()
                }
            } else {
                self.emptyView.removeFromSuperview()
            }
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
        self.addSubviews(self.tagView, self.resultView)
        self.tagView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(92)
        }
        self.resultView.snp.makeConstraints {
            $0.top.equalTo(self.tagView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }

        self.tagView.addSubviews(self.recentSearchLabel, self.tagCollectionView)
        self.recentSearchLabel.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(20)
        }
        self.tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.recentSearchLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.bottom.equalToSuperview().inset(24)
        }

        self.resultView.addSubviews(self.resultSearchLabel, self.resultCountLabel, self.resultCollectionView)
        self.resultSearchLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(20)
        }
        self.resultCountLabel.snp.makeConstraints {
            $0.trailing.top.equalToSuperview()
            $0.height.equalTo(20)
        }
        self.resultCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.resultSearchLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension SearchResultView {
    func updateResultData(_ data: ([String], [TotalSearchData.CollectionContent.Collection])) {
        self.resultData = data
        self.resultCountLabel.attributedText = .makeAttributedString(
            text: "\(data.1.count)건",
            font: .caption13MD,
            textColor: .textExtralight,
            lineHeight: 20
        )
    }
}

extension SearchResultView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === self.tagCollectionView {
            return self.resultData?.resultOfTags.count ?? 0
        } else {
            return self.resultData?.resultOfCollections.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === self.tagCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasicTagCell.reuseIdentifier, for: indexPath) as? BasicTagCell,
                  let tag = self.resultData?.resultOfTags[safe: indexPath.item] else { return UICollectionViewCell() }
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
                  let model = self.resultData?.resultOfCollections[safe: indexPath.item] else {
                return UICollectionViewCell()
            }
            cell.drawCell(model: model)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === self.tagCollectionView {
            guard let hashtagName = self.resultData?.resultOfTags[safe: indexPath.item] else { return .zero }
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
