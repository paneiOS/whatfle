//
//  MyPageHeaderView.swift
//  What?fle
//
//  Created by 이정환 on 11/6/24.
//

import UIKit

import SnapKit

final class MyPageHeaderView: UIView {
    private let titleLabel: UILabel = .init()

    private let moreButton: UIButton = {
        let button: UIButton = .init()
        var config: UIButton.Configuration = .plain()
        config.attributedTitle = .init(
            .makeAttributedString(
                text: "더보기",
                font: .body14MD,
                textColor: .textLight,
                lineHeight: 20
            )
        )
        config.image = .Icon.grayAddButton.resized(to: .init(width: 24, height: 24))
        config.imagePadding = 8
        config.imagePlacement = .trailing
        config.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        button.configuration = config
        return button
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.attributedText = .makeAttributedString(
            text: title,
            font: .body14MD,
            textColor: .textLight,
            lineHeight: 20
        )
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    private func setupUI() {
        self.addSubviews(self.titleLabel, self.moreButton)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(16)
        }
        self.moreButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
