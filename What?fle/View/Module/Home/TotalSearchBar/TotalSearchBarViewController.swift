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
    var resultData: BehaviorRelay<(tags: [String], collections: [TotalSearchData.CollectionContent.Collection])> { get }
    func dismissTotalSearchBar()
    func searchTerm(term: String)
//    func deleteItem(at index: Int)
}

final class TotalSearchBarViewController: UIViewController, TotalSearchBarPresentable, TotalSearchBarViewControllable {

    enum SearchState {
        case before
        case after
    }

    // MARK: - UIComponent

    private let beforeSearchView: UIView = .init()

    private let afterSearchView: UIView = {
        let view: UIView = .init()
        view.isHidden = true
        return view
    }()

    private lazy var searchBarView: SearchBarView = {
        let view: SearchBarView = .init()
        view.searchBar.delegate = self
        return view
    }()

    private lazy var tagStackView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.addArrangedSubviews(self.tagCollectionView, self.tagMoreButton)
        return stackView
    }()

    private lazy var tagCollectionView: TagCollectionView = {
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

    private lazy var searchRecentView: SearchRecentView = {
        let view: SearchRecentView = .init()
        view.delegate = self
        return view
    }()

    private let searchResultView = SearchResultView()

    // MARK: - Property

    weak var listener: TotalSearchBarPresentableListener?

    private let disposeBag = DisposeBag()

    private var searchArr: [String] = [] {
        didSet {
            self.tagCollectionView.reloadData()
        }
    }

    private var searchSate: SearchState = .before {
        didSet {
            switch searchSate {
            case .before:
                self.beforeSearchView.isHidden = false
                self.afterSearchView.isHidden = true
            case .after:
                self.beforeSearchView.isHidden = true
                self.afterSearchView.isHidden = false
            }
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
        view.backgroundColor = .white

        self.view.addSubviews(self.searchBarView, self.beforeSearchView, self.afterSearchView)
        self.searchBarView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UIApplication.shared.statusBarHeight + 8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        self.beforeSearchView.snp.makeConstraints {
            $0.top.equalTo(self.searchBarView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
        self.afterSearchView.snp.makeConstraints {
            $0.top.equalTo(self.searchBarView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }

        self.beforeSearchView.addSubviews( self.tagStackView, searchRecentView)
        self.tagStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.tagCollectionView.snp.makeConstraints {
            $0.height.equalTo(32)
        }
        self.tagMoreButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
        }
        searchRecentView.snp.makeConstraints {
            $0.top.equalTo(self.tagStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        self.afterSearchView.addSubview(searchResultView)
        searchResultView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupViewBinding() {
        self.listener?.recommendHashTags
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.tagCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        self.listener?.recentTerms
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] terms in
                guard let self else { return }
                self.searchRecentView.updateRecentSearchTerms(terms)
                self.searchRecentView.reloadData()
            })
            .disposed(by: disposeBag)

        self.listener?.resultData
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                self.searchResultView.updateResultData(data)
                self.searchSate = .after
            })
            .disposed(by: disposeBag)

        self.searchBarView.searchBar.rx.text
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                if let text, text.isEmpty {
                    self.searchSate = .before
                }
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
                    self.tagCollectionView.snp.removeConstraints()
                } else {
                    self.tagCollectionView.snp.makeConstraints {
                        $0.height.equalTo(32)
                    }
                }
                self.tagCollectionView.setScrollDirection(self.tagMoreButton.isSelected ? .vertical : .horizontal)
                self.tagCollectionView.collectionViewLayout.invalidateLayout()
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
              let tag = self.listener?.recommendHashTags.value[safe: indexPath.item] else {
            return UICollectionViewCell()
        }
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = self.listener?.recommendHashTags.value[safe: indexPath.item] else { return }
        self.searchBarView.searchBar.text = tag
        self.listener?.searchTerm(term: tag)
    }
}

extension TotalSearchBarViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.text else { return true }
        self.listener?.searchTerm(term: text)
        return true
    }
}

extension TotalSearchBarViewController: SearchRecentViewDelegate {
    func searchTerm(term: String) {
        self.searchBarView.searchBar.text = "#" + term
        self.listener?.searchTerm(term: term)
    }
}
