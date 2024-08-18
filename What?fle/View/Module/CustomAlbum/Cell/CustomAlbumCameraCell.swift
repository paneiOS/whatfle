//
//  CustomAlbumCameraCell.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import UIKit

final class CustomAlbumCameraCell: UICollectionViewCell {
    static let reuseIdentifier = "CustomAlbumCameraCell"

    // MARK: - UI

    private let cameraImageView: UIImageView = .init(image: .Icon.cameraIcon)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }

    private func setupUI() {
        self.contentView.backgroundColor = .GrayScale.g100
        self.contentView.addSubview(cameraImageView)
        self.cameraImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
    }
}
