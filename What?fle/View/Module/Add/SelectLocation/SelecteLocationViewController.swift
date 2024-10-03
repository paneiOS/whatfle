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
    func refreshRecentKeywordArray()
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

    private lazy var searchBarView: SearchBarView = {
        let view: SearchBarView = .init()
        view.setupPlaceholder("장소 검색하기")
        view.delegate = self
        return view
    }()

    private lazy var searchResultTableView: SearchTableView = {
        let tableView: SearchTableView = .init()
        tableView.register(SelectLocationCell.self, forCellReuseIdentifier: SelectLocationCell.reuseIdentifier)
        tableView.separatorColor = .lineExtralight
        tableView.separatorInset = .zero
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

    private lazy var recentTableView: SearchTableView = {
        let tableView: SearchTableView = .init()
        tableView.register(RecentSearchCell.self, forCellReuseIdentifier: RecentSearchCell.reuseIdentifier)
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
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewBinding()
        setupActionBinding()
        setupKeyboard()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SelectLocationViewController {
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviews(searchBarView, searchResultTableView, recentSearchView)
        self.searchBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        self.searchResultTableView.snp.makeConstraints {
            $0.top.equalTo(self.searchBarView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(Constants.bottomPadding)
        }
        self.recentSearchView.snp.makeConstraints {
            $0.top.equalTo(self.searchBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(8)
        }
        self.recentSearchView.addSubviews(recentSearchHeaderView, noSearchLabel, recentTableView)
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

        self.recentSearchHeaderView.addSubviews(recentSearchLabel, recentClearButton)
        self.recentSearchLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        self.recentClearButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
        }
    }

    private func setupViewBinding() {
        self.listener?.recentKeywordArray
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
            .bind(
                to: searchResultTableView.rx.items(
                    cellIdentifier: SelectLocationCell.reuseIdentifier,
                    cellType: SelectLocationCell.self
                )
            ) { _, model, cell in
                cell.drawCell(model: model)
            }
            .disposed(by: disposeBag)

        self.searchBarView.searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .filter { $0.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                if self.searchState == .afterSearch,
                   let keywordArray = self.listener?.recentKeywordArray.value {
                    self.searchState = keywordArray.isEmpty ? .beforeSearch : .beforeSearchWithHistory
                    self.listener?.refreshRecentKeywordArray()
                }
            })
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

        self.searchBarView.searchButton.rx.controlEvent(.touchUpInside)
            .withLatestFrom(searchBarView.searchBar.rx.text.orEmpty)
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                self.searchBarView.searchBar.endEditing(true)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                guard let self,
                      !query.isEmpty else { return }
                self.listener?.performSearch(with: query, more: false)
                if self.searchState != .afterSearch {
                    self.searchState = .afterSearch
                }
            })
            .disposed(by: disposeBag)

        self.searchBarView.closeButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.closeView()
            })
            .disposed(by: disposeBag)
    }

    private func activateSearchBar(state: Bool) {
        if state {
            searchBarView.totalView.layer.borderColor = UIColor.Core.primary.cgColor
            searchBarView.searchButtonImageView.tintColor = .black
        } else {
            searchBarView.totalView.layer.borderColor = UIColor.lineDefault.cgColor
            searchBarView.searchButtonImageView.tintColor = .textExtralight
        }
    }

    private func isTableViewScrolledToBottom() -> Bool {
        let offsetY = searchResultTableView.contentOffset.y
        let contentHeight = searchResultTableView.contentSize.height + Constants.bottomPadding
        let height = searchResultTableView.frame.size.height
        return offsetY + height > contentHeight + 50.0
    }

    private func setupKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.recentTableView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(keyboardSize.height)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.recentTableView.snp.updateConstraints {
            $0.bottom.equalToSuperview()
        }
    }
}

extension SelectLocationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activateSearchBar(state: true)
        self.searchBarView.closeButton.isHidden = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activateSearchBar(state: false)
        self.searchBarView.closeButton.isHidden = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.activateSearchBar(state: false)
        self.searchBarView.searchButton.sendActions(for: .touchUpInside)
        return true
    }
}

extension SelectLocationViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === self.searchResultTableView, decelerate, isTableViewScrolledToBottom() {
            self.listener?.performSearch(with: UserDefaultsManager.latestSearchLoad(type: .location), more: true)
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
                self.view.endEditing(true)
                searchBarView.searchBar.text = searchKeyward
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
