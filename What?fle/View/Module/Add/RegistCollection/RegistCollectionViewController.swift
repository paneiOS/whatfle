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
    var tags: BehaviorRelay<[TagType]> { get }
    func buttonTapped(index: Int)
    func addImage(_ image: UIImage)
    func removeImage()
    func showEditCollection()
    func closeCurrentRIB()
}

final class RegistCollectionViewController: UIVCWithKeyboard, RegistCollectionPresentable, RegistCollectionViewControllable {
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

    private let collectionTitleView: CustomTextView = {
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

    private let tagTitleView: CustomTextView = {
        let view: CustomTextView = .init(type: .onlyTitle)
        view.updateUI(title: "태그", isRequired: true)
        return view
    }()

    private lazy var tagCollectionView: TagCollectionView = {
        let collectionView: TagCollectionView = .init()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()

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

    private let coverRegistView: SwitchView = {
        let view: SwitchView = .init()
        view.draw(title: "표지 직접 등록")
        return view
    }()

    private let isPublicView: SwitchView = {
        let view: SwitchView = .init()
        view.draw(title: "전체공개")
        view.switchControl.isOn = true
        return view
    }()

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

    weak var listener: RegistCollectionPresentableListener?
    private var tags: [TagType] = []
    private var contentSizeObservation: NSKeyValueObservation?
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
        self.contentSizeObservation?.invalidate()

        contentSizeObservation?.invalidate()
        tagCollectionView.removeObserver(self, forKeyPath: "contentSize")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newSize = change?[.newKey] as? CGSize {
                tagCollectionView.snp.updateConstraints {
                    $0.height.equalTo(newSize.height)
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
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
        self.subView.addSubview(collectionTitleView)
        self.collectionTitleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        self.subView.addSubview(descriptionTextView)
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.collectionTitleView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }

        self.subView.addSubview(tagTitleView)
        self.tagTitleView.snp.makeConstraints {
            $0.top.equalTo(self.descriptionTextView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
        }

        self.subView.addSubview(tagCollectionView)
        self.tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.tagTitleView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }

        self.subView.addSubview(selectedLocationSubView)
        self.selectedLocationSubView.snp.makeConstraints {
            $0.top.equalTo(self.tagCollectionView.snp.bottom).offset(40)
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

        self.subView.addSubview(coverRegistView)
        self.coverRegistView.snp.makeConstraints {
            $0.top.equalTo(self.selectedLocationSubView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
        }

        self.subView.addSubview(imageView)
        self.imageView.snp.makeConstraints {
            $0.top.equalTo(self.coverRegistView.snp.bottom).offset(40)
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

        self.subView.addSubview(isPublicView)
        self.isPublicView.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func setupViewBinding() {
        guard let listener else { return }
        listener.tags
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tags in
                guard let self else { return }
                self.tags = tags
                self.tagCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        listener.selectedImage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                self.imageView.image = image
                self.addPhotoButton.isHidden = true
            })
            .disposed(by: disposeBag)

        listener.selectedLocations
            .observe(on: MainScheduler.instance)
            .bind(to: selectedLocationCollectionView.rx.items(
                cellIdentifier: SelectLocationResultCell.reuseIdentifier,
                cellType: SelectLocationResultCell.self)
            ) { (_, model, cell) in
                cell.drawCell(model: model)
            }
            .disposed(by: disposeBag)

        tagCollectionView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.contentSizeObservation = tagCollectionView.observe(\.contentSize, options: [.new]) { [weak self] _, change in
            guard let self = self, let newSize = change.newValue else { return }
            self.tagCollectionView.snp.updateConstraints {
                $0.height.equalTo(newSize.height)
            }
        }
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

//        self.coverRegistView.switchControl.rx.controlEvent(.valueChanged)
//            .subscribe(onNext: { [weak self] in
//                guard let self else { return }
//                self.coverRegistView.switchControl.isOn.toggle()
//            })
//            .disposed(by: disposeBag)

        self.coverRegistView.switchControl.rx.isOn
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bool in
                guard let self else { return }
//                self.imageView.snp.updateConstraints {
//                    $0.height.equalTo(bool ? 160 : 0)
//                }
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

extension RegistCollectionViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell,
              let cellType = self.tags[safe: indexPath.row] else { return UICollectionViewCell() }
        cell.drawCell(cellType: cellType)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellType = self.tags[safe: indexPath.item] else { return }
        switch cellType {
        case .button:
            print("button tapped")
        case .addedSelectedButton:
            print("addedSelectedButton tapped")
        case .selected, .deselected:
            listener?.buttonTapped(index: indexPath.item)
            collectionView.reloadItems(at: [indexPath])
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellType = tags[safe: indexPath.item] else { return .zero }
        return CGSize(width: cellType.width, height: cellType.height)
    }
}
