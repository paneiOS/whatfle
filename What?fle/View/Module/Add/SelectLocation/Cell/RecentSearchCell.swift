//
//  RecentSearchCell.swift
//  What?fle
//
//  Created by 이정환 on 3/21/24.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

protocol RecentSearchCellDelegate: AnyObject {
    func deleteItem(at index: Int)
}

final class RecentSearchCell: UITableViewCell {
    static let reuseIdentifier = "RecentSearchCell"
    weak var delegate: RecentSearchCellDelegate?
    private let disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 2
        label.font = .body14MD
        label.textColor = .textExtralight
        return label
    }()

    private let deleteButton: UIControl = {
        let control: UIControl = .init()
        let imageView: UIImageView = {
            let view: UIImageView = .init()
            view.image = .Icon.xLineMd
            view.tintColor = .textExtralight
            return view
        }()
        control.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return control
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
        setupBinding()
        self.selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview()
        }

        contentView.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.size.equalTo(24)
        }
    }

    func drawCell(string: String) {
        self.titleLabel.text = string
    }

    private func setupBinding() {
        deleteButton.rx.controlEvent(.touchUpInside)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                delegate?.deleteItem(at: self.tag)
            })
            .disposed(by: disposeBag)
    }
}
