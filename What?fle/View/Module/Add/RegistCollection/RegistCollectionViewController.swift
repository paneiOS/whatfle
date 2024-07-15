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
    var isHiddenDimmedView: BehaviorRelay<Bool> { get }
    func buttonTapped(index: Int)
    func addImage(_ image: UIImage)
    func removeImage()
    func removeTag(index: Int)
    func showEditCollection()
    func showAddTagRIB(tags: [TagType])
    func registCollection(data: CollectionData)
    func popToCurrentRIB()
}

final class RegistCollectionViewController: UIVCWithKeyboard, RegistCollectionPresentable, RegistCollectionViewControllable {
    private enum Constants {
        static let contentsWidth: CGFloat = UIApplication.shared.width - 48
    }

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

    private let titleInputView: CustomTextView = {
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

    private let tagRegistButton: UIControl = {
        let control: UIControl = .init()
        let label: UILabel = .init()
        label.isUserInteractionEnabled = false
        label.attributedText = .makeAttributedString(
            text: "태그 직접입력",
            font: .body14MD,
            textColor: .textLight,
            lineHeight: 20
        )
        let imageView: UIImageView = .init(image: .addButton)
        imageView.isUserInteractionEnabled = false
        [label, imageView].forEach {
            control.addSubview($0)
        }
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(8)
        }
        imageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.equalTo(label.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(24)
        }
        return control
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

    private let coverImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let deleteButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.xCircleFilled, for: .normal)
        button.isHidden = true
        return button
    }()

    private let addPhotoButton: UIButton = {
        let button: UIButton = .init()
        button.layer.cornerRadius = 4
        button.backgroundColor = .Core.background
        return button
    }()

    private let addPhotoPlacehold: UIView = {
        let view: UIView = .init()
        view.isUserInteractionEnabled = false
        let imageView: UIImageView = {
            let imageView: UIImageView = .init(image: .camera)
            imageView.tintColor = .textExtralight
            imageView.isUserInteractionEnabled = false
            return imageView
        }()
        let placeholdLabel: UILabel = {
            let label: UILabel = .init()
            label.isUserInteractionEnabled = false
            label.attributedText = .makeAttributedString(
                text: "눌러서 사진 추가",
                font: .title16MD,
                textColor: .textExtralight,
                lineHeight: 24
            )
            return label
        }()
        [imageView, placeholdLabel].forEach {
            view.addSubview($0)
        }
        imageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.size.equalTo(24)
        }
        placeholdLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.top.bottom.trailing.equalToSuperview()
        }
        return view
    }()

    private let dimmedView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .Core.dimmed20
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()

    private let isCoverRegistView: SwitchView = {
        let view: SwitchView = .init()
        view.draw(title: "표지 직접 등록")
        return view
    }()

    private let isPublicView: SwitchView = {
        let view: SwitchView = .init()
        view.draw(title: "전체공개")
        return view
    }()

    weak var listener: RegistCollectionPresentableListener?
    private var contentSizeObservation: NSKeyValueObservation?
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")

        contentSizeObservation?.invalidate()
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
            $0.width.equalTo(Constants.contentsWidth)
        }

        scrollView.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(Constants.contentsWidth)
        }
        self.subView.addSubview(titleInputView)
        self.titleInputView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }

        self.subView.addSubview(descriptionTextView)
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.titleInputView.snp.bottom).offset(24)
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

        self.subView.addSubview(tagRegistButton)
        self.tagRegistButton.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
        }

        self.subView.addSubview(selectedLocationSubView)
        self.selectedLocationSubView.snp.makeConstraints {
            $0.top.equalTo(self.tagRegistButton.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(90)
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
            $0.size.equalTo(64)
        }

        self.subView.addSubview(isCoverRegistView)
        self.isCoverRegistView.snp.makeConstraints {
            $0.top.equalTo(self.selectedLocationSubView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }

        self.subView.addSubview(coverImageView)
        self.coverImageView.snp.makeConstraints {
            $0.top.equalTo(self.isCoverRegistView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }

        self.subView.addSubview(addPhotoButton)
        self.addPhotoButton.snp.makeConstraints {
            $0.top.equalTo(self.isCoverRegistView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        self.addPhotoButton.addSubview(deleteButton)
        self.deleteButton.snp.makeConstraints {
            $0.top.trailing.equalTo(self.coverImageView)
            $0.size.equalTo(50)
        }
        self.addPhotoButton.addSubview(addPhotoPlacehold)
        self.addPhotoPlacehold.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        self.subView.addSubview(isPublicView)
        self.isPublicView.snp.makeConstraints {
            $0.top.equalTo(self.coverImageView.snp.bottom).offset(24)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }

        view.addSubview(dimmedView)
        self.dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension RegistCollectionViewController {
    private func setupViewBinding() {
        let isEmptyTitleInputView = self.titleInputView.textView.rx.text.orEmpty.map { $0.isEmpty }.distinctUntilChanged()
        let isEmptyTagObservable = self.listener?.tags.asObservable()
            .map { tags in
                return tags.filter { tag in
                    switch tag {
                    case .addedSelectedButton, .selected:
                        return true
                    default:
                        return false
                    }
                }.isEmpty
            }
            .distinctUntilChanged() ?? Observable.just(false)

        Observable.combineLatest(isEmptyTitleInputView, isEmptyTagObservable)
            .map { !$0 && !$1 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self else { return }
                self.customNavigationBar.setRightButton(title: "저장", isEnabled: isEnabled)
            })
            .disposed(by: disposeBag)

        listener?.tags
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.tagCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        listener?.selectedImage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                if let image {
                    self.coverImageView.image = image
                    addPhotoButton.isHidden = true
                    addPhotoPlacehold.isHidden = true
                } else {
                    addPhotoButton.isHidden = false
                    addPhotoPlacehold.isHidden = false
                }
            })
            .disposed(by: disposeBag)

        listener?.selectedLocations
            .observe(on: MainScheduler.instance)
            .bind(to: selectedLocationCollectionView.rx.items(
                cellIdentifier: SelectLocationResultCell.reuseIdentifier,
                cellType: SelectLocationResultCell.self)
            ) { (_, model, cell) in
                cell.drawCell(model: model)
            }
            .disposed(by: disposeBag)

        listener?.isHiddenDimmedView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isHidden in
                guard let self = self else { return }
                self.dimmedView.isHidden = isHidden
            })
            .disposed(by: disposeBag)

        contentSizeObservation = tagCollectionView.observe(\.contentSize, options: [.new]) { [weak self] _, change in
            guard let self = self, let newSize = change.newValue else { return }
            self.tagCollectionView.snp.updateConstraints {
                $0.height.equalTo(newSize.height)
            }
        }
    }

    private func setupActionBinding() {
        self.customNavigationBar.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                listener?.popToCurrentRIB()
            })
            .disposed(by: disposeBag)

        self.customNavigationBar.rightButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.registCollection(
                    data: .init(
                        accountID: AppConfigs.UserInfo.accountID,
                        title: self.titleInputView.textView.text,
                        description: self.descriptionTextView.textView.text,
                        isPublic: isPublicView.switchControl.isOn,
                        hashtags: self.listener?.tags.value.map { $0.title } ?? [],
                        places: self.listener?.selectedLocations.value.compactMap { $0.id } ?? [],
                        isActiveCover: isCoverRegistView.switchControl.isOn
                    )
                )
            })
            .disposed(by: disposeBag)

        self.addPhotoButton.rx.tap
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

        self.deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.removeImage()
            })
            .disposed(by: disposeBag)

        self.tagRegistButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: {[weak self] in
                guard let self = self,
                      let tags = listener?.tags.value else { return }
                self.dimmedView.isHidden = false
                self.listener?.showAddTagRIB(tags: tags)
            })
            .disposed(by: disposeBag)

        self.editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.showEditCollection()
            })
            .disposed(by: disposeBag)

        self.isCoverRegistView.switchControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.isCoverRegistView.switchControl.isOn.toggle()
            })
            .disposed(by: disposeBag)

        self.isPublicView.switchControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.isPublicView.switchControl.isOn.toggle()
            })
            .disposed(by: disposeBag)

        self.isCoverRegistView.switchControl.rx.isOn
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isOn in
                guard let self else { return }
                self.coverImageView.snp.updateConstraints {
                    $0.height.equalTo(isOn ? Constants.contentsWidth : 0)
                }
                self.addPhotoButton.snp.updateConstraints {
                    $0.height.equalTo(isOn ? Constants.contentsWidth : 0)
                }
                if isOn {
                    if self.listener?.selectedImage.value != nil {
                        addPhotoButton.isHidden = true
                        addPhotoPlacehold.isHidden = true
                    } else {
                        addPhotoButton.isHidden = false
                        addPhotoPlacehold.isHidden = false
                    }
                } else {
                    addPhotoButton.isHidden = true
                    addPhotoPlacehold.isHidden = true
                }
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
        return self.listener?.tags.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell,
              let tags = listener?.tags.value,
              let cellType = tags[safe: indexPath.row] else { return UICollectionViewCell() }
        cell.delegate = self
        cell.drawCell(cellType: cellType)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tags = listener?.tags.value,
              let cellType = tags[safe: indexPath.item] else { return }
        switch cellType {
        case .addedSelectedButton:
            break
        case .selected, .deselected:
            listener?.buttonTapped(index: indexPath.item)
            collectionView.reloadItems(at: [indexPath])
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tags = listener?.tags.value,
              let cellType = tags[safe: indexPath.item] else { return .zero }
        return CGSize(width: cellType.width, height: cellType.height)
    }
}

extension RegistCollectionViewController: TagCellDelegate {
    func didTapCloseButton(in cell: TagCell) {
        if let indexPath = tagCollectionView.indexPath(for: cell) {
            listener?.removeTag(index: indexPath.item)
        }
    }
}
