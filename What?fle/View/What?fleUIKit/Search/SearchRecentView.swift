//
//  SearchRecentView.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import UIKit

import RxSwift

protocol SearchRecentViewDelegate: AnyObject {
    func searchTerm(term: String)
}

final class SearchRecentView: UIView {

    // MARK: - UI Component

    private let headerView: UIView = .init()

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
        tableView.dataSource = self
        return tableView
    }()

    // MARK: - property

    var recentSearchTerms: [String] = [] {
        didSet {
            self.recentTableView.reloadData()
        }
    }

    weak var delegate: SearchRecentViewDelegate?

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
        self.setupAction()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
        self.setupAction()
    }

    private func setupUI() {
        self.addSubviews(self.headerView, self.recentTableView)
        self.headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        self.recentTableView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.headerView.addSubviews(self.recentSearchLabel, self.recentClearButton)
        self.recentSearchLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        self.recentClearButton.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
        }
    }

    private func setupAction() {
        self.recentClearButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                UserDefaultsManager.historyAllRemove(type: .home)
                self.recentSearchTerms.removeAll()
            })
            .disposed(by: self.disposeBag)
    }
}

extension SearchRecentView {
    func updateRecentSearchTerms(_ terms: [String]) {
        self.recentSearchTerms = terms
    }

    func reloadData() {
        self.recentTableView.reloadData()
    }
}

extension SearchRecentView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentSearchTerms.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let term = self.recentSearchTerms[safe: indexPath.item] else { return }
        delegate?.searchTerm(term: term)
    }
}

extension SearchRecentView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchCell.reuseIdentifier) as? RecentSearchCell,
              let tag = self.recentSearchTerms[safe: indexPath.item] else { return UITableViewCell() }
        cell.tag = indexPath.item
        cell.drawCell(string: tag)
        cell.delegate = self
        return cell
    }
}

extension SearchRecentView: RecentSearchCellDelegate {
    func deleteItem(at index: Int) {
        self.recentSearchTerms = UserDefaultsManager.recentSearchRemove(type: .home, index: index)
    }
}
