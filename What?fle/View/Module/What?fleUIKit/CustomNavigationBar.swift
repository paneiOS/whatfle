//
//  CustomNavigationBar.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import UIKit
import SnapKit

final class CustomNavigationBar: UIView {

    let backButton: UIButton = {
        let button: UIButton = .init()
        var config = UIButton.Configuration.plain()
        config.image = .arrowLeftLine
        config.imagePlacement = .all
        config.imagePadding = 8
        button.configuration = config
        return button
    }()

    private let navigationTitle: UILabel = .init()

    let rightButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        return button
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        [backButton, navigationTitle, rightButton].forEach {
            addSubview($0)
        }
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
        navigationTitle.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
        }
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
    }

    func setNavigationTitle(_ title: String) {
        navigationTitle.attributedText = .makeAttributedString(
            text: title,
            font: .title16XBD,
            textColor: .GrayScale.g900,
            lineHeight: 24
        )
    }

    func setRightButton(title: String, isEnabled: Bool = false) {
        rightButton.isHidden = false
        rightButton.setAttributedTitle(
            .makeAttributedString(
                text: title,
                font: .title16XBD,
                textColor: isEnabled ? .Core.primary : .Core.primaryDisabled,
                lineHeight: 21
            ),
            for: .normal
        )
    }
}
