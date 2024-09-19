//
//  TagCell.swift
//  What?fle
//
//  Created by JeongHwan Lee on 7/6/24.
//

import UIKit

import RxSwift
import SnapKit

protocol TagCellDelegate: AnyObject {
    func didTapCloseButton(in cell: TagCell)
}

final class TagCell: UICollectionViewCell {
    static let reuseIdentifier = "TagCell"

    private let label: UILabel = .init()
    private let closeButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.Icon.xLineMd, for: .normal)
        button.tintColor = .GrayScale.g300
        return button
    }()

    weak var delegate: TagCellDelegate?
    private let disposeBag = DisposeBag()

    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        return CGSize(width: labelSize.width, height: labelSize.height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupBinding()
    }

    func drawCell(cellType: TagType) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            if case .addedSelectedButton = cellType {
                $0.leading.equalToSuperview().inset(10)
            } else {
                $0.leading.equalToSuperview().inset(12)
            }
        }

        switch cellType {
        case .addedSelectedButton(let title):
            label.attributedText = .makeAttributedString(
                text: title,
                font: cellType.font,
                textColor: .Core.p400,
                lineHeight: 20
            )
            contentView.addSubview(closeButton)
            self.closeButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(label.snp.trailing).offset(4)
                $0.trailing.equalToSuperview().inset(10)
                $0.size.equalTo(24)
            }
            contentView.backgroundColor = .Core.p100
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.Core.primary.cgColor

        case .selected(let model):
            label.attributedText = .makeAttributedString(
                text: model.hashtagName,
                font: cellType.font,
                textColor: .Core.p400,
                lineHeight: 20
            )
            contentView.backgroundColor = .Core.p100
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.Core.primary.cgColor

        case .deselected(let model):
            label.attributedText = .makeAttributedString(
                text: model.hashtagName,
                font: .body14MD,
                textColor: .textExtralight,
                lineHeight: 20
            )
            contentView.backgroundColor = .white
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.GrayScale.g100.cgColor
        }
    }

    private func setupBinding() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                delegate?.didTapCloseButton(in: self)
            })
            .disposed(by: disposeBag)
    }
}
