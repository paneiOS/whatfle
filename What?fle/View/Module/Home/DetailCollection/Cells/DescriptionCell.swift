//
//  DescriptionCell.swift
//  What?fle
//
//  Created by 이정환 on 8/8/24.
//

import UIKit

protocol DescriptionCellDelegate: AnyObject {
    func cell(_ cell: DescriptionCell, didUpdateHeight height: CGFloat)
}

final class DescriptionCell: UICollectionViewCell {
    private enum Constants {
        static let cellWidth: CGFloat = UIApplication.shared.width - 32
        static let interPadding: CGFloat = 56
    }

    static let reuseIdentifier = "DescriptionCell"

    weak var delegate: DescriptionCellDelegate?

    private let collectionTitle: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionTextView: UITextView = {
        let textView: UITextView = .init()
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        textView.contentInset = .zero
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    private func setupUI() {
        contentView.addSubviews(self.collectionTitle, self.descriptionTextView)
        self.collectionTitle.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.collectionTitle.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }

    func drawCell(model: DetailCollectionModel) {
        collectionTitle.attributedText = .makeAttributedString(
            text: model.title,
            font: .title20XBD,
            textColor: .textDefault,
            lineHeight: 28
        )
        descriptionTextView.attributedText = .makeAttributedString(
            text: model.description,
            font: .body14MD,
            textColor: .textLight,
            lineHeight: 20
        )
        let totalHeight: CGFloat = (collectionTitle.attributedText?.height(containerWidth: Constants.cellWidth) ?? 0) + descriptionTextView.attributedText.height(containerWidth: Constants.cellWidth) + Constants.interPadding
        delegate?.cell(self, didUpdateHeight: totalHeight)
    }
}
