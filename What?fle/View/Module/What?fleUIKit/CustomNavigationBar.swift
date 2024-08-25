//
//  CustomNavigationBar.swift
//  What?fle
//
//  Created by 이정환 on 4/6/24.
//

import UIKit
import SnapKit

final class CustomNavigationBar: UIView {

    let backButton: UIButton = .init()

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
        self.addSubviews(backButton, navigationTitle, rightButton)
        self.backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
        self.navigationTitle.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing).offset(4)
            $0.centerY.equalToSuperview()
        }
        self.rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
    }

    func setNavigationTitle(_ title: String = "", alignment: NSTextAlignment = .left, buttonImage: UIImage = .Icon.arrowLeftLine, buttonColor: UIColor? = nil) {
        navigationTitle.attributedText = .makeAttributedString(
            text: title,
            font: .title16XBD,
            textColor: .GrayScale.g900,
            lineHeight: 24,
            alignment: alignment
        )
        var config = UIButton.Configuration.plain()
        if let buttonColor {
            config.image = buttonImage.withTintColor(buttonColor)
        } else {
            config.image = buttonImage
        }
        config.imagePlacement = .all
        config.imagePadding = 8
        backButton.configuration = config
        if alignment == .center {
            navigationTitle.snp.remakeConstraints {
                $0.center.equalToSuperview()
            }
        }
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

    func setRightButton(image: UIImage) {
        self.rightButton.isHidden = false
        self.rightButton.setImage(image, for: .normal)
    }
}
