//
//  CustomAlbumInteractor.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import Photos
import RIBs
import RxSwift
import RxCocoa
import UIKit

protocol CustomAlbumRouting: ViewableRouting {}

protocol CustomAlbumPresentable: Presentable {
    var listener: CustomAlbumPresentableListener? { get set }
}

protocol CustomAlbumListener: AnyObject {
    func addPhotos(images: [UIImage])
    func closeCustomAlbum()
}

final class CustomAlbumInteractor: PresentableInteractor<CustomAlbumPresentable>, CustomAlbumInteractable, CustomAlbumPresentableListener {

    weak var router: CustomAlbumRouting?
    weak var listener: CustomAlbumListener?

    let selectedIndex = BehaviorRelay<[Int]>(value: [])
    let thumbnailArray = BehaviorRelay<[PHAsset]>(value: [])

    deinit {
        print("\(self) is being deinit")
    }

    override init(presenter: CustomAlbumPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func addPhoto(image: UIImage) {
        listener?.addPhotos(images: [image])
    }

    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self else { return }
            switch status {
            case .authorized, .restricted:
                self.loadThumbnail()
            case .notDetermined:
                break
            default:
                fatalError("Unknown photo library authorization status")
            }
        }
    }

    func closeCustomAlbum() {
        listener?.closeCustomAlbum()
    }

    private func loadThumbnail() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var newAssets: [PHAsset] = []
        fetchResult.enumerateObjects { (asset, _, _) in
            newAssets.append(asset)
        }
        self.thumbnailArray.accept(newAssets)
    }

    func addIndex(index: Int) {
        let currentValues = selectedIndex.value + [index]
        selectedIndex.accept(currentValues)
    }

    func removeIndex(index: Int) {
        let currentValues = selectedIndex.value.filter { $0 != index }
        selectedIndex.accept(currentValues)
    }

    func addPhoto(index: Int) {
        addIndex(index: index)
        addPhotos()
    }

    func addPhotos() {
        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        for index in selectedIndex.value {
            if let asset = thumbnailArray.value[safe: index] {
                dispatchGroup.enter()
                let imageManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = false
                requestOptions.deliveryMode = .highQualityFormat

                imageManager.requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFill,
                    options: requestOptions
                ) { image, _ in
                    guard let image else { return }
                    images.append(image)
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.listener?.addPhotos(images: images)
        }
    }
}
