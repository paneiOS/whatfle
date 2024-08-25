//
//  CustomPresentHeader.swift
//  What?fle
//
//  Created by 이정환 on 5/3/24.
//

import UIKit
import RxSwift
import SnapKit

final class CustomPresentHeader: UIView {
    private let disposeBag = DisposeBag()

    let closeButton: UIButton = {
        let button: UIButton = .init()
        var config = UIButton.Configuration.plain()
        config.image = .Icon.xLineLg
        config.imagePlacement = .all
        config.imagePadding = 8
        button.configuration = config
        return button
    }()

    private let headerTitle: UILabel = .init()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        self.addSubviews(headerTitle, closeButton)
        self.headerTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        self.closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
    }

    func setHeaderTitle(_ title: String) {
        headerTitle.attributedText = .makeAttributedString(
            text: title,
            font: .title16XBD,
            textColor: .GrayScale.g900,
            lineHeight: 24
        )
    }
}
