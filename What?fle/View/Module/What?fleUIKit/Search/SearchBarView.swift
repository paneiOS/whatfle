//
//  SearchBarView.swift
//  What?fle
//
//  Created by 이정환 on 9/20/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class SearchBarView: UIView {
    private let totalView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()

    private let searchBarView: UIView = {
        let view: UIView = .init()
        view.layer.borderColor = UIColor.lineDefault.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        return view
    }()

    lazy var searchBar: UITextField = {
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
        view.image = .Icon.search
        view.tintColor = .textExtralight
        return view
    }()

    private let closeButton: UIControl = {
        let control: UIControl = .init()
        let imageView: UIImageView = {
            let view: UIImageView = .init()
            view.image = .Icon.xLineLg
            return view
        }()
        control.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        control.isHidden = true
        return control
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
        self.setupActionBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
        self.setupActionBinding()
    }

    private let disposeBag = DisposeBag()

    private func setupUI() {
        self.addSubview(self.totalView)
        self.totalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.totalView.addArrangedSubviews(self.searchBarView, self.closeButton)
        self.closeButton.snp.makeConstraints {
            $0.width.equalTo(44)
        }
        self.searchBarView.addSubviews(self.searchBar, self.searchButton)
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
    }

    private func setupActionBinding() {
        self.closeButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.searchBar.endEditing(false)
            })
            .disposed(by: self.disposeBag)
    }
}

extension SearchBarView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.closeButton.isHidden = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.closeButton.isHidden = true
    }
}
