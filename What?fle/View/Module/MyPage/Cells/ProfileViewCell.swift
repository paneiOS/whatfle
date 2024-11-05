//
//  ProfileViewCell.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import UIKit

final class ProfileViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileViewCell"

    private let profileImage: ImageView = {
        let view: ImageView = .init()
        view.layer.cornerRadius = 32
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lineLight.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let nicknameLabel: UILabel = .init()

    private let userNameTrailingLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "님,",
            font: .title15SB,
            textColor: .textLight,
            lineHeight: 24
        )
        return label
    }()

    private let placeholderLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "오늘의 장소를 기록해보세요!",
            font: .title15RG,
            textColor: .textLight,
            lineHeight: 24
        )
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
    }

    private func setupUI() {
        self.contentView.addSubviews(
            self.profileImage,
            self.nicknameLabel,
            self.userNameTrailingLabel,
            self.placeholderLabel
        )
        self.profileImage.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.leading.equalToSuperview()
            $0.size.equalTo(64)
        }
        self.nicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalTo(self.profileImage.snp.trailing).offset(8)
        }
        self.userNameTrailingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalTo(self.nicknameLabel.snp.trailing).offset(4)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        self.placeholderLabel.snp.makeConstraints {
            $0.leading.equalTo(self.profileImage.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
    }

    func drawCell(model: UserInfo) {
        self.profileImage.loadImage(from: model.profileImagePath, placeholder: .placeholder)
        self.nicknameLabel.attributedText = .makeAttributedString(
            text: model.nickname ?? "",
            font: .title16XBD,
            textColor: .textDefault,
            lineHeight: 24
        )
    }
}
