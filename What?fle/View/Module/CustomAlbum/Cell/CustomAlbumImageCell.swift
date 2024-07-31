//
//  CustomAlbumImageCell.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import Photos
import UIKit

final class CustomAlbumImageCell: UICollectionViewCell {
    static let reuseIdentifier = "CustomAlbumImageCell"

    // MARK: - UI

    private let selectImageView: UIImageView = {
        let imageView: UIImageView = .init(image: .selectImageOff)
        imageView.isUserInteractionEnabled = false
        imageView.backgroundColor = .clear
        return imageView
    }()

    private let imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        self.contentView.addSubview(imageView)
        self.imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.contentView.addSubview(selectImageView)
        self.selectImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8)
            $0.size.equalTo(24)
        }
    }

    func drawCell(image: UIImage) {
        imageView.image = image
    }

    func selecteCell(isSelected: Bool) {
        selectImageView.image = isSelected ? .selectImageOn : .selectImageOff
    }

    func drawCell(with asset: PHAsset, isSingleSelect: Bool) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic

        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: requestOptions
        ) { [weak self] image, _ in
            guard let self else { return }
            self.imageView.image = image
        }

        selectImageView.image = isSelected ? .selectImageOn : .selectImageOff
        selectImageView.isHidden = isSingleSelect
    }
}
