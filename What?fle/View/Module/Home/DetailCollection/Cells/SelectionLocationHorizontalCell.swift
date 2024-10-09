//
//  SelectionLocationHorizontalCell.swift
//  What?fle
//
//  Created by 이정환 on 8/9/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SelectionLocationHorizontalCell: UICollectionViewCell {
    static let reuseIdentifier = "SelectionLocationHorizontalCell"

    private let lineView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .lineLight
        return view
    }()

    private let selectedLocationTitleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "이 컬렉션에 포함된 장소들",
            font: .caption12BD,
            textColor: .textLight,
            lineHeight: 20
        )
        return label
    }()

    private lazy var selectLocationCollectionView: SelectLocationCollectionView = .init()

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    private func setupUI() {
        contentView.addSubviews(self.lineView, self.selectedLocationTitleLabel, self.selectLocationCollectionView)
        self.lineView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        self.selectedLocationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.lineView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        self.selectLocationCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.selectedLocationTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(88)
        }
    }

    func drawCell(places: [PlaceRegistration]) {
        selectLocationCollectionView.items.accept(places)
    }
}
