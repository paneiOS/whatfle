//
//  AddPhotoControl.swift
//  What?fle
//
//  Created by 이정환 on 4/17/24.
//

import UIKit

final class AddPhotoControl: UIControl {
    private let stackView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.isUserInteractionEnabled = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView: UIImageView = .init(image: .Icon.camera)
        imageView.tintColor = .Core.primary
        return imageView
    }()
    private let placeholdLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "눌러서 사진 추가",
            font: .title16MD,
            textColor: .Core.primary,
            lineHeight: 24
        )
        return label
    }()
    private let countLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "(0/10)",
            font: .caption13MD,
            textColor: .Core.primary,
            lineHeight: 20
        )
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setupUI() {
        backgroundColor = .Core.p100

        self.addSubview(stackView)
        self.stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        stackView.addArrangedSubviews(imageView, placeholdLabel, countLabel)
        imageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }

    func updateButtonState(isImageEmpty: Bool) {
        if isImageEmpty {
            stackView.axis = .horizontal
            stackView.spacing = 8
            placeholdLabel.isHidden = false
            self.layer.cornerRadius = 0
            self.removeShadow()
        } else {
            stackView.axis = .vertical
            stackView.spacing = 2
            placeholdLabel.isHidden = true
            self.layer.cornerRadius = 40
            self.addShadow(yPoint: 2, blur: 10, opacity: 0.1)
        }
    }

    func updatePhoto(count: Int) {
        countLabel.attributedText = .makeAttributedString(
            text: "(\(count)/10)",
            font: .caption13MD,
            textColor: .Core.primary,
            lineHeight: 20)
    }

    func hideCountLabel() {
        self.stackView.removeArrangedSubview(self.countLabel)
        self.countLabel.removeFromSuperview()
    }
}
