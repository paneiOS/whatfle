//
//  RegistCollectionViewController.swift
//  What?fle
//
//  Created by 이정환 on 4/17/24.
//

import PhotosUI
import RIBs
import RxCocoa
import RxSwift
import SnapKit
import UIKit

protocol RegistCollectionPresentableListener: AnyObject {
    var selectedImage: BehaviorRelay<UIImage?> { get }
    var selectedLocations: BehaviorRelay<[PlaceRegistration]> { get }
    func addImage(_ image: UIImage)
    func removeImage()
    func showEditCollection()
    func closeCurrentRIB()
}

final class RegistCollectionViewController: UIVCWithKeyboard, RegistCollectionPresentable, RegistCollectionViewControllable {
    weak var listener: RegistCollectionPresentableListener?
    private let disposeBag = DisposeBag()

    private lazy var customNavigationBar: CustomNavigationBar = {
        let view: CustomNavigationBar = .init()
        view.setNavigationTitle("컬랙션 생성")
        view.setRightButton(title: "저장")
        return view
    }()

    private let scrollView: UIScrollView = {
        let scrollView: UIScrollView = .init()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    private let subView: UIView = .init()

    private let addPhotoButton: AddPhotoControl = {
        let control: AddPhotoControl = .init()
        control.hideCountLabel()
        control.layer.cornerRadius = 4
        return control
    }()

    private let imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let deleteButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.xCircleFilled, for: .normal)
        return button
    }()

    private let collectionTitle: CustomTextView = {
        let view: CustomTextView = .init(type: .withoutTitle)
        view.updateUI(placehold: "컬렉션 이름")
        return view
    }()

    private let descriptionTextView: CustomTextView = {
        let view: CustomTextView = .init()
        view.updateUI(title: "설명", isRequired: false, placehold: "컬렉션에 대한 설명 작성하기")
        return view
    }()

    private let selectedLocationSubView: UIView = .init()

    private lazy var selectedLocationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.itemSize = .init(width: 64, height: 90)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            SelectLocationResultCell.self,
            forCellWithReuseIdentifier: SelectLocationResultCell.reuseIdentifier
        )
        return collectionView
    }()

    private let editButton: UIButton = {
        let button: UIButton = .init()
        button.backgroundColor = .Core.primary
        button.layer.cornerRadius = 4
        button.setAttributedTitle(
            .makeAttributedString(
                text: "수정",
                font: .body14MD,
                textColor: .white,
                lineHeight: 20
            ),
            for: .normal
        )
        return button
    }()

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewBinding()
        setupActionBinding()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(28)
            $0.width.equalTo(UIApplication.shared.width - 48)
        }

        scrollView.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIApplication.shared.width - 48)
        }

        subView.addSubview(imageView)
        self.imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }

        view.addSubview(deleteButton)
        self.deleteButton.snp.makeConstraints {
            $0.top.trailing.equalTo(self.imageView)
            $0.size.equalTo(50)
        }

        view.addSubview(addPhotoButton)
        self.addPhotoButton.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(self.imageView)
            $0.height.equalTo(160)
        }

        self.subView.addSubview(collectionTitle)
        self.collectionTitle.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }

        self.subView.addSubview(descriptionTextView)
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.collectionTitle.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }

        self.subView.addSubview(selectedLocationSubView)
        self.selectedLocationSubView.snp.makeConstraints {
            $0.top.equalTo(self.descriptionTextView.snp.bottom).offset(40)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        [selectedLocationCollectionView, editButton].forEach {
            self.selectedLocationSubView.addSubview($0)
        }
        self.selectedLocationCollectionView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        self.editButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(self.selectedLocationCollectionView.snp.trailing).offset(8)
            $0.bottom.equalToSuperview().inset(25)
            $0.size.equalTo(64)
        }
    }

    private func setupViewBinding() {
        guard let listener else { return }
        listener.selectedImage
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                self.imageView.image = image
                self.addPhotoButton.isHidden = true
            })
            .disposed(by: disposeBag)
        listener.selectedLocations
            .bind(to: selectedLocationCollectionView.rx.items(
                cellIdentifier: SelectLocationResultCell.reuseIdentifier,
                cellType: SelectLocationResultCell.self)
            ) { (_, model, cell) in
                cell.drawCell(model: model)
            }
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        self.customNavigationBar.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: true)
                self.listener?.closeCurrentRIB()
            })
            .disposed(by: disposeBag)

        self.addPhotoButton.rx.controlEvent(.touchUpInside)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.view.endEditing(true)
                var configuration = PHPickerConfiguration()
                configuration.filter = .any(of: [.images])
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        self.deleteButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.removeImage()
                self.addPhotoButton.isHidden = false
            })
            .disposed(by: disposeBag)

        self.editButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.showEditCollection()
            })
            .disposed(by: disposeBag)
    }
}

extension RegistCollectionViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        for itemProvider in results.map({ $0.itemProvider }) where itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                guard let self, let image = image as? UIImage, let listener = self.listener else { return }
                DispatchQueue.main.async {
                    listener.addImage(image)
                }
            }
        }
    }
}
