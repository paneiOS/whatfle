//
//  SelectLocationViewController.swift
//  What?fle
//
//  Created by 이정환 on 2/25/24.
//

import RIBs
import RxSwift
import RxCocoa
import SnapKit

import UIKit

protocol SelectLocationPresentableListener: AnyObject {
    var recentKeywordArray: BehaviorRelay<[String]> { get }
    var searchResultArray: BehaviorRelay<[KakaoSearchDocumentsModel]> { get }
    func performSearch(with query: String, more: Bool)
    func closeView()
    func deleteItem(at index: Int)
    func allDeleteItem()
    func selectItem(at index: Int)
}

final class SelectLocationViewController: UIViewController, SelectLocationPresentable, SelectLocationViewControllable {
    private enum Constants {
        static let bottomPadding: CGFloat = 8.0
    }
    private enum SearchState {
        case beforeSearch
        case beforeSearchWithHistory
        case afterSearch
    }

    weak var listener: SelectLocationPresentableListener?
    private let disposeBag = DisposeBag()

    private var searchState: SearchState = .beforeSearch {
        didSet {
            switch searchState {
            case .beforeSearch:
                self.searchResultTableView.isHidden = true
                self.recentSearchView.isHidden = false
                self.recentTableView.isHidden = true
                self.noSearchLabel.isHidden = false
            case .beforeSearchWithHistory:
                self.searchResultTableView.isHidden = true
                self.recentSearchView.isHidden = false
                self.recentTableView.isHidden = false
                self.noSearchLabel.isHidden = true
            case .afterSearch:
                self.searchResultTableView.isHidden = false
                self.recentSearchView.isHidden = true
            }
        }
    }

    private let headerView: UIView = .init()

    private let searchBarView: UIView = {
        let view: UIView = .init()
        view.layer.borderColor = UIColor.lineDefault.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        return view
    }()

    private lazy var searchBar: UITextField = {
        let searchBar: UITextField = .init()
        searchBar.delegate = self
        searchBar.font = .body14MD
        searchBar.textColor = .black
        searchBar.clearButtonMode = .whileEditing
        searchBar.returnKeyType = .search
        searchBar.attributedPlaceholder = NSAttributedString(
            string: "장소 검색하기",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textExtralight,
                         NSAttributedString.Key.font: UIFont.body14MD]
        )
        return searchBar
    }()

    private let searchButton: UIControl = .init()

    private let searchButtonImageView: UIImageView = {
        let view: UIImageView = .init()
        view.image = .search
        view.tintColor = .textExtralight
        return view
    }()

    private let closeButton: UIControl = {
        let control: UIControl = .init()
        let imageView: UIImageView = {
            let view: UIImageView = .init()
            view.image = .xLineLg
            return view
        }()
        control.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        return control
    }()

    private lazy var searchResultTableView: UITableView = {
        let tableView: UITableView = .init()
        tableView.register(SelectLocationCell.self, forCellReuseIdentifier: SelectLocationCell.reuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorColor = .lineExtralight
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.isHidden = true
        tableView.delegate = self
        return tableView
    }()

    private let recentSearchView: UIView = .init()

    private let recentSearchHeaderView: UIView = .init()

    private let recentSearchLabel: UILabel = {
        let label: UILabel = .init()
        label.text = "최근 검색"
        label.font = .body14SB
        label.textColor = .textLight
        return label
    }()

    private let recentClearButton: UIControl = {
        let control: UIControl = .init()
        let label: UILabel = {
            let label: UILabel = .init()
            label.text = "전체 삭제"
            label.font = .caption13MD
            label.textColor = .textLight
            return label
        }()
        control.addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return control
    }()

    private lazy var recentTableView: UITableView = {
        let tableView: UITableView = .init()
        tableView.register(RecentSearchCell.self, forCellReuseIdentifier: RecentSearchCell.reuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.isHidden = true
        tableView.isScrollEnabled = false
        tableView.delegate = self
        return tableView
    }()

    private let noSearchLabel: UILabel = {
        let label: UILabel = .init()
        label.text = "최근 검색한 장소가 없습니다."
        label.font = .body14MD
        label.textColor = .textExtralight
        return label
    }()

    deinit {
        print("\(Self.self) is being deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewBinding()
        setupActionBinding()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SelectLocationViewController {
    private func setupUI() {
        view.backgroundColor = .white
        [headerView, searchResultTableView, recentSearchView].forEach {
            view.addSubview($0)
        }
        self.headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        self.searchResultTableView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(Constants.bottomPadding)
        }
        self.recentSearchView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(8)
        }
        [searchBarView, closeButton].forEach {
            headerView.addSubview($0)
        }
        self.searchBarView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        self.closeButton.snp.makeConstraints {
            $0.width.equalTo(44)
            $0.leading.equalTo(self.searchBarView.snp.trailing).offset(4)
            $0.top.trailing.bottom.equalToSuperview()
        }
        [searchBar, searchButton].forEach {
            searchBarView.addSubview($0)
        }
        self.searchBar.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
        }
        self.searchButton.snp.makeConstraints {
            $0.width.equalTo(44)
            $0.top.trailing.bottom.equalToSuperview()
            $0.leading.equalTo(self.searchBar.snp.trailing)
        }
        self.searchButton.addSubview(self.searchButtonImageView)
        self.searchButtonImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        [recentSearchHeaderView, noSearchLabel, recentTableView].forEach {
            self.recentSearchView.addSubview($0)
        }
        self.recentSearchHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        self.noSearchLabel.snp.makeConstraints {
            $0.top.equalTo(self.recentSearchHeaderView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        self.recentTableView.snp.makeConstraints {
            $0.top.equalTo(self.recentSearchHeaderView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        [recentSearchLabel, recentClearButton].forEach {
            self.recentSearchHeaderView.addSubview($0)
        }
        self.recentSearchLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        self.recentClearButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
        }
    }

    private func setupViewBinding() {
        self.listener?.recentKeywordArray
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] item in
                guard let self else { return }
                self.searchState = !item.isEmpty ? .beforeSearchWithHistory : .beforeSearch
            })
            .bind(
                to: recentTableView.rx.items(
                    cellIdentifier: RecentSearchCell.reuseIdentifier,
                    cellType: RecentSearchCell.self
                )
            ) { [weak self] (index, element, cell) in
                guard let self else { return }
                cell.tag = index
                cell.delegate = self
                cell.drawCell(string: element)
            }
            .disposed(by: disposeBag)

        self.listener?.searchResultArray
            .observe(on: MainScheduler.instance)
            .bind(
                to: searchResultTableView.rx.items(
                    cellIdentifier: SelectLocationCell.reuseIdentifier,
                    cellType: SelectLocationCell.self
                )
            ) { _, model, cell in
                cell.drawCell(model: model)
            }
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        self.recentClearButton.rx.controlEvent(.touchUpInside)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.allDeleteItem()
            })
            .disposed(by: disposeBag)

        self.searchButton.rx.controlEvent(.touchUpInside)
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                self.searchBar.endEditing(true)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                guard let self,
                      !query.isEmpty else { return }
                self.listener?.performSearch(with: query, more: false)
                if self.searchState != .afterSearch {
                    self.searchState = .afterSearch
                }
                self.searchResultTableView.reloadData()
            })
            .disposed(by: disposeBag)

        self.closeButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.closeView()
            })
            .disposed(by: disposeBag)
    }

    private func activateSearchBar(state: Bool) {
        if state {
            searchBarView.layer.borderColor = UIColor.Core.primary.cgColor
            searchButtonImageView.tintColor = .black
        } else {
            searchBarView.layer.borderColor = UIColor.lineDefault.cgColor
            searchButtonImageView.tintColor = .textExtralight
        }
    }

    private func isTableViewScrolledToBottom() -> Bool {
        let offsetY = searchResultTableView.contentOffset.y
        let contentHeight = searchResultTableView.contentSize.height + Constants.bottomPadding
        let height = searchResultTableView.frame.size.height
        return offsetY + height > contentHeight + 50.0
    }
}

extension SelectLocationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activateSearchBar(state: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activateSearchBar(state: false)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.activateSearchBar(state: false)
        searchButton.sendActions(for: .touchUpInside)
        return true
    }
}

extension SelectLocationViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate, isTableViewScrolledToBottom() {
            self.listener?.performSearch(with: UserDefaultsManager.latestSearchLoad(), more: true)
        }
    }
}

extension SelectLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === self.searchResultTableView {
            return 96
        } else if tableView === self.recentTableView {
            return 52
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === self.searchResultTableView {
            listener?.selectItem(at: indexPath.row)
        } else if tableView === self.recentTableView {
            if let searchKeyward = listener?.recentKeywordArray.value[indexPath.row] {
                self.listener?.performSearch(with: searchKeyward, more: false)
                if self.searchState != .afterSearch {
                    self.searchState = .afterSearch
                }
            }
        }
    }
}

extension SelectLocationViewController: RecentSearchCellDelegate {
    func deleteItem(at index: Int) {
        listener?.deleteItem(at: index)
    }
}
