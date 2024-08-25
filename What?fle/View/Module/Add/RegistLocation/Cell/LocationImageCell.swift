//
//  LocationImageCell.swift
//  What?fle
//
//  Created by 이정환 on 4/2/24.
//

import SnapKit
import UIKit

protocol LocationImageCellDelegate: AnyObject {
    func deleteButtonTapped(inCell cell: UICollectionViewCell)
}

final class LocationImageCell: UICollectionViewCell {
    static let reuseIdentifier = "LocationImageCell"
    weak var delegate: LocationImageCellDelegate?

    private let placeImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let deleteButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.Icon.xLineShadow, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        setupButton()
    }

    private func setupLayout() {
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true

        contentView.addSubview(self.placeImage)
        self.placeImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.placeImage.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(40)
        }
    }

    private func setupButton() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    func drawCell(image: UIImage) {
        placeImage.image = image
    }

    @objc private func deleteButtonTapped() {
        delegate?.deleteButtonTapped(inCell: self)
    }
}
