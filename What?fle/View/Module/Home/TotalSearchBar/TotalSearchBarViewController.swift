//
//  TotalSearchBarViewController.swift
//  What?fle
//
//  Created by 이정환 on 10/1/24.
//

import UIKit

import RIBs
import RxCocoa
import RxSwift
import SnapKit

protocol TotalSearchBarPresentableListener: AnyObject {
    var recommendHashTags: BehaviorRelay<[String]> { get }
    var recentTerms: BehaviorRelay<[String]> { get }
    func dismissTotalSearchBar()
//    func deleteItem(at index: Int)
}

final class TotalSearchBarViewController: UIViewController, TotalSearchBarPresentable, TotalSearchBarViewControllable {

    // MARK: - UIComponent

    private let searchBarView: SearchBarView = .init()

    private lazy var tagStackView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.addArrangedSubviews(self.searchHistoryCollectionView, self.tagMoreButton)
        return stackView
    }()

    private lazy var searchHistoryCollectionView: TagCollectionView = {
        let view: TagCollectionView = .init()
        view.register(BasicTagCell.self, forCellWithReuseIdentifier: BasicTagCell.reuseIdentifier)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.setScrollDirection(.horizontal)
        return view
    }()

    private let tagMoreButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.Icon.arrowDownMd, for: .normal)
        button.setAttributedTitle(
            .makeAttributedString(
                text: "태그 더보기",
                font: .body14MD,
                textColor: .textLight,
                lineHeight: 20
            ),
            for: .normal
        )
        var config: UIButton.Configuration = .plain()
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.background.backgroundColor = .clear
        button.configuration = config
        return button
    }()
    
    private var searchRecentView: SearchRecentViewDelegate = SearchRecentView()

    // MARK: - Property

    weak var listener: TotalSearchBarPresentableListener?

    private let disposeBag = DisposeBag()

    private var searchArr: [String] = [] {
        didSet {
            self.searchHistoryCollectionView.reloadData()
        }
    }

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupViewBinding()
        self.setupActionBinding()
    }

    private func setupUI() {
        guard let searchRecentView = self.searchRecentView as? SearchRecentView else { return }
        view.backgroundColor = .white

        self.view.addSubviews(self.searchBarView, self.tagStackView, searchRecentView)
        self.searchBarView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UIApplication.shared.statusBarHeight + 8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        self.tagStackView.snp.makeConstraints {
            $0.top.equalTo(self.searchBarView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        self.searchHistoryCollectionView.snp.makeConstraints {
            $0.height.equalTo(32)
        }

        self.tagMoreButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }

        searchRecentView.snp.makeConstraints {
            $0.top.equalTo(self.tagStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupViewBinding() {
        self.listener?.recommendHashTags
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.searchHistoryCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        self.listener?.recentTerms
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] terms in
                guard let self else { return }
                self.searchRecentView.updateRecentSearchTerms(terms)
            })
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        self.searchBarView.closeButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.dismissTotalSearchBar()
            })
            .disposed(by: self.disposeBag)

        self.tagMoreButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.tagMoreButton.isSelected.toggle()
                if self.tagMoreButton.isSelected {
                    self.searchHistoryCollectionView.snp.removeConstraints()
                } else {
                    self.searchHistoryCollectionView.snp.makeConstraints {
                        $0.height.equalTo(32)
                    }
                }
                self.searchHistoryCollectionView.setScrollDirection(self.tagMoreButton.isSelected ? .vertical : .horizontal)
                self.searchHistoryCollectionView.collectionViewLayout.invalidateLayout()
            })
            .disposed(by: self.disposeBag)
    }
}

extension TotalSearchBarViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listener?.recommendHashTags.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasicTagCell.reuseIdentifier, for: indexPath) as? BasicTagCell,
              let tag = self.listener?.recommendHashTags.value[safe: indexPath.row] else { return UICollectionViewCell() }
        cell.view.backgroundColor = .Core.background
        cell.drawLabel(tag: .makeAttributedString(
            text: tag,
            font: .body14MD,
            textColor: .textLight,
            lineHeight: 20
        ))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let hashtagName = self.listener?.recommendHashTags.value[safe: indexPath.item] else { return .zero }
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