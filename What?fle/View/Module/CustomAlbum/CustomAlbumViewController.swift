//
//  CustomAlbumViewController.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import Photos
import RIBs
import RxCocoa
import RxSwift
import UIKit

protocol CustomAlbumPresentableListener: AnyObject {
    var selectedIndex: BehaviorRelay<[Int]> { get }
    var thumbnailArray: BehaviorRelay<[PHAsset]> { get }
    func addIndex(index: Int)
    func removeIndex(index: Int)
    func addPhoto(image: UIImage)
    func addPhotos()
    func addPhoto(index: Int)
    func requestPhotoLibraryAccess()
    func closeCustomAlbum()
}

final class CustomAlbumViewController: UIViewController, CustomAlbumPresentable, CustomAlbumViewControllable {
    enum Constants {
        static let cellWidth: CGFloat = (UIApplication.shared.width - 48.0) / 3
    }

    // MARK: - UI

    private lazy var customNavigationBar: CustomNavigationBar = {
        let navigationBar: CustomNavigationBar = .init()
        navigationBar.setNavigationTitle("사진첩", alignment: .center, buttonImage: .Icon.xLineLg)
        if !isSingleSelect {
            navigationBar.setRightButton(title: "완료")
        }
        return navigationBar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(CustomAlbumCameraCell.self, forCellWithReuseIdentifier: CustomAlbumCameraCell.reuseIdentifier)
        collectionView.register(CustomAlbumImageCell.self, forCellWithReuseIdentifier: CustomAlbumImageCell.reuseIdentifier)
        return collectionView
    }()

    weak var listener: CustomAlbumPresentableListener?
    private let disposeBag = DisposeBag()

    private var isSingleSelect: Bool = false
    private let imagePickerController = UIImagePickerController()
    private var images: [UIImage] = []
    private var thumbnails: [PHAsset] = []

    init(isSingleSelect: Bool) {
        self.isSingleSelect = isSingleSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewBinding()
        setupActionBinding()
        listener?.requestPhotoLibraryAccess()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(customNavigationBar)
        self.customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }

        view.addSubview(collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupViewBinding() {
        self.listener?.thumbnailArray
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] thumbnails in
                guard let self else { return }
                self.thumbnails = thumbnails
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)

        let isEnabledObservable = listener?.selectedIndex.map { !$0.isEmpty }.share()
        isEnabledObservable?
            .bind(to: customNavigationBar.rightButton.rx.isEnabled)
            .disposed(by: disposeBag)
        isEnabledObservable?
            .filter { [weak self] _ in
                guard let self else { return false }
                return !self.isSingleSelect
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self else { return }
                self.customNavigationBar.setRightButton(title: "완료", isEnabled: isEnabled)
            })
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        self.customNavigationBar.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                listener?.closeCustomAlbum()
            })
            .disposed(by: disposeBag)

        self.customNavigationBar.rightButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.addPhotos()
            })
            .disposed(by: disposeBag)
    }
}

extension CustomAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0,
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomAlbumCameraCell.reuseIdentifier, for: indexPath) as? CustomAlbumCameraCell {
            return cell
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomAlbumImageCell.reuseIdentifier, for: indexPath) as? CustomAlbumImageCell,
                  let thumbnail = self.thumbnails[safe: indexPath.item - 1] {
            cell.drawCell(with: thumbnail, isSingleSelect: self.isSingleSelect)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.cellWidth, height: Constants.cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.indexPathsForSelectedItems?.count ?? 0 < 10 else { return }
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomAlbumImageCell {
            guard !self.isSingleSelect else {
                listener?.addPhoto(index: indexPath.item)
                return
            }
            cell.selecteCell(isSelected: true)
            listener?.addIndex(index: indexPath.item - 1)
        } else {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomAlbumImageCell {
            cell.selecteCell(isSelected: false)
            listener?.removeIndex(index: indexPath.item - 1)
        } else {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true)
        }
    }
}

extension CustomAlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            listener?.addPhoto(image: image)
        }
    }
}
