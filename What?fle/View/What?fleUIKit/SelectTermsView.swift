//
//  SelectTermsView.swift
//  What?fle
//
//  Created by 이정환 on 9/22/24.
//

import UIKit

import SnapKit

final class SelectTermsView: UIView {
    let selectButton: SelectButton = .init()

    private let moveButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.Icon.arrowRightMd, for: .normal)
        return button
    }()

    var isSelected: Bool {
        get {
            self.selectButton.isSelected
        }
        set {
            self.selectButton.isSelected = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    private func setupUI() {
        self.addSubviews(self.selectButton, self.moveButton)
        self.selectButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview()
        }
        self.moveButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(24)
        }
    }

    func setTitle(title: String) {
        self.selectButton.setAttributedTitle(
            .makeAttributedString(
                text: title,
                font: .title16XBD,
                textColor: .textDefault,
                lineHeight: 24
            ),
            for: .normal
        )
    }
}
