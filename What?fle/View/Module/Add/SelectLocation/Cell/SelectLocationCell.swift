//
//  SelectLocationCell.swift
//  What?fle
//
//  Created by 이정환 on 3/21/24.
//

import SnapKit
import UIKit

final class SelectLocationCell: UITableViewCell {
    static let reuseIdentifier = "SelectLocationCell"

    private let placeImage: UIImageView = {
        let view: UIImageView = .init(image: .placehold)
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lineExtralight.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let titleView: UIView = .init()
    let titleLabel: UILabel = {
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

    private var checkBox: UIImageView = {
        let checkBox: UIImageView = .init(image: .selectOff)
        checkBox.isHidden = true
        return checkBox
    }()

    private var opacityView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .init(white: 1, alpha: 0.4)
        view.isHidden = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLayout()
        self.selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkBox.image = .selectOff
    }

    private func setupLayout() {
        contentView.addSubview(self.placeImage)
        self.placeImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.size.equalTo(64)
        }
        contentView.addSubview(self.titleView)
        self.titleView.snp.makeConstraints {
            $0.centerY.equalTo(self.placeImage.snp.centerY)
            $0.leading.equalTo(self.placeImage.snp.trailing).offset(16)
        }
        self.titleView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.titleView.addSubview(self.subTitleLabel)
        self.subTitleLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(self.titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.addSubview(self.checkBox)
        self.checkBox.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(titleView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(0)
        }

        contentView.addSubview(self.opacityView)
        self.opacityView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func drawCell(model: KakaoSearchDocumentsModel) {
        titleLabel.text = model.placeName
        subTitleLabel.text = model.addressName
        placeImage.image = model.categoryGroupCode.image
    }

    func drawCheckTypeCell(model: KakaoSearchDocumentsModel) {
        drawCell(model: model)
        self.checkBox.isHidden = false
        self.checkBox.snp.updateConstraints {
            $0.leading.equalTo(titleView.snp.trailing).offset(16)
            $0.size.equalTo(24)
        }
    }

    private func drawCell(model: PlaceRegistration) {
        titleLabel.text = model.placeName
        subTitleLabel.text = model.roadAddress
        opacityView.isHidden = !model.isEmptyImageURLs
    }

    func drawCheckTypeCell(model: PlaceRegistration, order: Int) {
        drawCell(model: model)
        self.checkBox.isHidden = false
        self.checkBox.snp.updateConstraints {
            $0.leading.equalTo(titleView.snp.trailing).offset(16)
            $0.size.equalTo(24)
        }
        updateCheckBox(order: order)
    }

    func updateCheckBox(order: Int?) {
        switch order {
        case 1:
            checkBox.image = .select1
        case 2:
            checkBox.image = .select2
        case 3:
            checkBox.image = .select3
        case 4:
            checkBox.image = .select4
        case 5:
            checkBox.image = .select5
        case 6:
            checkBox.image = .select6
        case 7:
            checkBox.image = .select7
        case 8:
            checkBox.image = .select8
        default:
            checkBox.image = .selectOff
        }
    }
}
