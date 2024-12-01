//
//  SelectionLocationVerticalListCell.swift
//  What?fle
//
//  Created by 이정환 on 8/12/24.
//

import UIKit

import RxSwift
import RxCocoa

protocol SelectionLocationVerticalListCellDelegate: AnyObject {
    func cell(_ cell: SelectionLocationVerticalListCell, didUpdateHeight height: CGFloat, at index: Int)
}

final class SelectionLocationVerticalListCell: UICollectionViewCell {
    private enum Constants {
        enum Height {
            static let pagerCollectionViewHeight: CGFloat = UIApplication.shared.width / 375 * 400
            static let placeInfoViewHeight: CGFloat = 96
            static let profileViewMinumHeight: CGFloat = 56
        }
        static let interPadding: CGFloat = 16
    }
    static let reuseIdentifier = "SelectionLocationVerticalListCell"

    weak var delegate: SelectionLocationVerticalListCellDelegate?

    private let pagerImageView: PagerImageView = .init()

    private let placeInfoView: UIView = .init()

    private let placeImage: UIImageView = {
        let view: UIImageView = .init()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lineExtralight.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 2
        label.font = .body14SB
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .caption12RG
        label.textColor = .textExtralight
        return label
    }()

    private let favoriteButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.Icon.favoriteOff, for: .normal)
        return button
    }()

    private let profileView: UIView = .init()

    private let profileImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let triangleView: TriangleView = .init()

    private let descriptionTextView: UITextView = {
        let view: UITextView = .init()
        view.contentInset = .init(top: 10, left: 12, bottom: 10, right: 12)
        view.backgroundColor = .Core.background
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isEditable = false
        return view
    }()

    private var model: PublishSubject<PlaceRegistration> = .init()

    var index: Int?

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
        self.bindUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupUI()
        self.bindUI()
    }

    private func setupUI() {
        self.contentView.addSubviews(self.pagerImageView, self.placeInfoView, self.profileView)
        self.pagerImageView.snp.makeConstraints {
            $0.top.leading.trailing.width.equalToSuperview()
            $0.height.equalTo(Constants.Height.pagerCollectionViewHeight)
        }
        self.placeInfoView.addSubviews(self.placeImage, self.titleLabel, self.subTitleLabel, self.favoriteButton)
        self.placeInfoView.snp.makeConstraints {
            $0.top.equalTo(self.pagerImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(Constants.Height.placeInfoViewHeight)
        }
        self.placeImage.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(64)
        }
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeImage.snp.top)
            $0.leading.equalTo(self.placeImage.snp.trailing).offset(8)
        }
        self.subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(self.placeImage.snp.trailing).offset(8)
            $0.bottom.equalTo(self.placeImage.snp.bottom)
        }
        self.favoriteButton.snp.makeConstraints {
            $0.top.equalTo(self.placeImage.snp.top)
            $0.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(32)
        }
        self.profileView.addSubviews(self.profileImageView, self.triangleView, self.descriptionTextView)
        self.profileView.snp.makeConstraints {
            $0.top.equalTo(self.placeInfoView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(Constants.Height.profileViewMinumHeight)
        }
        self.profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(24)
        }
        self.triangleView.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom)
            $0.leading.equalToSuperview().inset(8)
            $0.width.equalTo(9)
            $0.height.equalTo(8)
        }
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.triangleView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }

    private func bindUI() {
        model.subscribe(onNext: { [weak self] place in
            guard let self else { return }
            self.pagerImageView.configure(with: place.imageURLs)

            self.placeImage.image = place.categoryGroupCode.image
            self.titleLabel.attributedText = .makeAttributedString(
                text: place.placeName,
                font: .body14SB,
                textColor: .textDefault,
                lineHeight: 20
            )
            self.subTitleLabel.attributedText = .makeAttributedString(
                text: place.roadAddress,
                font: .caption13MD,
                textColor: .textExtralight,
                lineHeight: 20
            )
            self.profileImageView.image = .placehold
            self.descriptionTextView.attributedText = .makeAttributedString(
                text: place.description,
                font: .body14RG,
                textColor: .textLight,
                lineHeight: 20
            )
            let profileViewHeight = place.description.isEmpty ? 0 : Constants.Height.profileViewMinumHeight + descriptionTextView.attributedText.height(containerWidth: UIApplication.shared.width - 56) + 20
            self.profileView.isHidden = profileViewHeight == 0
            self.profileView.snp.updateConstraints {
                $0.height.equalTo(profileViewHeight)
            }
            if let index = self.index {
                self.updateTotalHeight(profileViewHeight: profileViewHeight, at: index)
            }
        }).disposed(by: disposeBag)
    }

    func drawCell(model: PlaceRegistration, at index: Int) {
        self.index = index
        self.model.onNext(model)
    }
}

extension SelectionLocationVerticalListCell {
    private func updateTotalHeight(profileViewHeight: CGFloat, at index: Int) {
        let totalHeight: CGFloat = Constants.Height.pagerCollectionViewHeight + Constants.Height.placeInfoViewHeight + profileViewHeight + Constants.interPadding
        delegate?.cell(self, didUpdateHeight: totalHeight, at: index)
    }
}

extension SelectionLocationVerticalListCell: PagerImageViewDelegate {
    func pagerImageView(_ pagerImageView: PagerImageView, didSelectImageAt index: Int) {}
}
