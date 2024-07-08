//
//  TagCell.swift
//  What?fle
//
//  Created by JeongHwan Lee on 7/6/24.
//

import SnapKit
import UIKit

enum TagType {
    case button(String)
    case addedSelectedButton(String)
    case selected(String)
    case deselected(String)

    var title: String {
        switch self {
        case .button(let title), .addedSelectedButton(let title), .selected(let title), .deselected(let title):
        return title
        }
    }

    var font: UIFont {
        return .body14MD
    }

    var width: CGFloat {
        let attributedString = NSAttributedString(string: self.title, attributes: [.font: self.font])
        return ceil(attributedString.size().width) + 24
    }

    var height: CGFloat {
        return 32
    }

    func toggle() -> TagType {
        switch self {
        case .selected(let title):
            return .deselected(title)
        case .deselected(let title):
            return .selected(title)
        default: return self
        }
    }
}

final class TagCell: UICollectionViewCell {
    static let identifier = "TagCell"

    private let label: UILabel = .init()
    private let closeButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.xLineMd, for: .normal)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        return CGSize(width: labelSize.width, height: labelSize.height)
    }

    func drawCell(cellType: TagType) {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        contentView.addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.equalToSuperview().inset(12)
            switch cellType {
            case .addedSelectedButton:
                break
            default:
                $0.trailing.equalToSuperview().inset(12)
            }
        }

        switch cellType {
        case .button(let title):
            label.attributedText = .makeAttributedString(
                text: title,
                font: cellType.font,
                textColor: .textLight,
                lineHeight: 20
            )
            contentView.backgroundColor = .white
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.lineDefault.cgColor

        case .addedSelectedButton(let title):
            label.attributedText = .makeAttributedString(
                text: title,
                font: cellType.font,
                textColor: .Core.p400,
                lineHeight: 20
            )

            self.closeButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(self.label.snp.trailing).offset(4)
                $0.trailing.equalToSuperview().inset(12)
                $0.size.equalTo(24)
            }

        case .selected(let title):
            label.attributedText = .makeAttributedString(
                text: title,
                font: cellType.font,
                textColor: .Core.p400,
                lineHeight: 20
            )
            contentView.backgroundColor = .Core.p100
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.Core.primary.cgColor

        case .deselected(let title):
            label.attributedText = .makeAttributedString(
                text: title,
                font: .body14MD,
                textColor: .textExtralight,
                lineHeight: 20
            )
            contentView.backgroundColor = .white
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.GrayScale.g100.cgColor
        }
    }
}
