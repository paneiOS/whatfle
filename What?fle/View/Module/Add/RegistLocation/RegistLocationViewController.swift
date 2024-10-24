//
//  RegistLocationViewController.swift
//  What?fle
//
//  Created by 이정환 on 3/5/24.
//

import RIBs
import RxCocoa
import RxSwift
import UIKit

protocol RegistLocationPresentableListener: AnyObject {
    var imageArray: BehaviorRelay<[UIImage]> { get }
    var isSelectLocation: BehaviorRelay<Bool> { get }
    var model: KakaoSearchDocumentsModel? { get }
    var accountID: Int { get }
    func showSelectLocation()
    func registPlace(_ registration: PlaceRegistration, imageData: [Data])
    func closeRegistLocation()
    func showCustomAlbum()
}

final class RegistLocationViewController: ScrollKeyboardVC, RegistLocationViewControllable {
    private lazy var customNavigationBar: CustomNavigationBar = {
        let view: CustomNavigationBar = .init()
        view.setNavigationTitle("장소 기록하기")
        return view
    }()

    private let scrollView: UIScrollView = {
        let scrollView: UIScrollView = .init()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()

    private let subView: UIView = .init()

    private let locationView: UIView = .init()

    private let locationLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "장소*",
            font: .title16XBD,
            textColor: .textDefault,
            lineHeight: 24,
            additionalAttributes: [(text: "*", attribute: [.foregroundColor: UIColor.red])]
        )
        return label
    }()

    private let addLocationTextField: UITextField = {
        let textField: UITextField = .init()
        textField.isUserInteractionEnabled = false
        return textField
    }()

    private let addLocationImageView: UIImageView = .init(image: UIImage(systemName: "plus"))

    private lazy var addLocationView: UIControl = {
        let control: UIControl = .init()
        addLocationTextField.attributedPlaceholder = .makeAttributedString(
            text: "장소 추가하기",
            font: .title15RG,
            textColor: .textExtralight,
            lineHeight: 24
        )
        let underlineView: UIView = {
            let view: UIView = .init()
            view.backgroundColor = .lineDefault
            return view
        }()
        addLocationImageView.tintColor = .textExtralight
        control.addSubviews(addLocationTextField, addLocationImageView, underlineView)
        addLocationTextField.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        addLocationImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        underlineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        return control
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.itemSize = .init(width: 168, height: 224)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(LocationImageCell.self, forCellWithReuseIdentifier: LocationImageCell.reuseIdentifier)
        return collectionView
    }()

    private let addPhotoButton: AddPhotoControl = .init()
    private let visitView: UIView = .init()

    private let visitLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "방문일자*",
            font: .title16XBD,
            textColor: .textDefault,
            lineHeight: 24,
            additionalAttributes: [(text: "*", attribute: [.foregroundColor: UIColor.red])]
        )
        return label
    }()

    private lazy var visitTextField: DatePickerTextField = {
        let textField: DatePickerTextField = .init()
        textField.attributedText = NSAttributedString.makeAttributedString(
            text: Date().formattedYYMMDDWithDot,
            font: .body14MD,
            textColor: .textDefault,
            lineHeight: 20
        )
        return textField
    }()

    private let memoView: CustomTextView = {
        let view: CustomTextView = .init()
        view.updateUI(title: "메모", placehold: "장소에 대한 기록 남기기")
        return view
    }()

    private let saveButton: UIButton = {
        let button: UIButton = .init()
        button.backgroundColor = .Core.primaryDisabled
        button.layer.cornerRadius = 4
        button.setAttributedTitle(
            .makeAttributedString(
                text: "저장",
                font: .title16MD,
                textColor: .white,
                lineHeight: 24
            ),
            for: .normal
        )
        return button
    }()

    weak var listener: RegistLocationPresentableListener?
    private let disposeBag = DisposeBag()

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
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
            $0.width.equalTo(UIApplication.shared.width)
        }

        scrollView.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIApplication.shared.width)
        }

        subView.addSubview(locationView)
        locationView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        locationView.addSubviews(locationLabel, addLocationView)
        locationLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        addLocationView.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
        }

        subView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(addLocationView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(224)
        }
        subView.addSubview(addPhotoButton)
        addPhotoButton.snp.makeConstraints {
            $0.edges.equalTo(collectionView.snp.edges)
        }

        subView.addSubview(visitView)
        visitView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        visitView.addSubviews(visitLabel, visitTextField)
        visitLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        visitTextField.snp.makeConstraints {
            $0.top.equalTo(visitLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
        }

        subView.addSubview(memoView)
        memoView.snp.makeConstraints {
            $0.top.equalTo(visitView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        subView.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.top.equalTo(visitView.snp.bottom).offset(198)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(56)
        }
    }

    private func setupViewBinding() {
        listener?.imageArray
            .bind(
                to: collectionView.rx.items(
                    cellIdentifier: LocationImageCell.reuseIdentifier,
                    cellType: LocationImageCell.self
                )
            ) { [weak self] (_, element, cell) in
                guard let self else { return }
                cell.delegate = self
                cell.drawCell(image: element)
            }
            .disposed(by: disposeBag)

        listener?.imageArray
            .map { $0.isEmpty }
            .subscribe(onNext: { [weak self] bool in
                guard let self, let count = listener?.imageArray.value.count else { return }
                addPhotoButton.snp.remakeConstraints {
                    if bool {
                        $0.edges.equalTo(self.collectionView.snp.edges)
                    } else {
                        self.addPhotoButton.snp.remakeConstraints {
                            $0.size.equalTo(80)
                            $0.trailing.equalTo(self.collectionView.snp.trailing).inset(-8)
                            $0.bottom.equalTo(self.collectionView.snp.bottom).inset(16)
                        }
                    }
                    self.addPhotoButton.updatePhoto(count: count)
                }
                addPhotoButton.updateButtonState(isImageEmpty: bool)
            })
            .disposed(by: disposeBag)

        let isEnabledObservable = Observable.combineLatest(
            listener?.isSelectLocation.asObservable() ?? Observable.just(false),
            memoView.textView.rx.text.orEmpty
        )
        .map { isSelectLocation, memoText in
            isSelectLocation && !memoText.isEmpty
        }.share()

        isEnabledObservable
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        isEnabledObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bool in
                guard let self else { return }
                self.saveButton.backgroundColor = bool ? .Core.primary : .Core.primaryDisabled
                saveButton.setAttributedTitle(
                    .makeAttributedString(
                        text: "저장",
                        font: .title16MD,
                        textColor: bool ? .black : .white,
                        lineHeight: 24
                    ),
                    for: .normal
                )
            })
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        self.customNavigationBar.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                listener?.closeRegistLocation()
            })
            .disposed(by: disposeBag)

        self.addLocationView.rx.controlEvent(.touchUpInside)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                guard let self else { return }
                self.listener?.showSelectLocation()
            }
            .disposed(by: disposeBag)

        self.addPhotoButton.rx.controlEvent(.touchUpInside)
            .filter { [weak self] _ in (self?.listener?.imageArray.value.count ?? 10) < 10}
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.view.endEditing(true)
                listener?.showCustomAlbum()
            })
            .disposed(by: disposeBag)

        self.saveButton.rx.controlEvent(.touchUpInside)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let listener,
                      let model = listener.model else { return }
                self.memoView.endEditing(true)
                listener.registPlace(
                    .init(
                        accountID: listener.accountID,
                        description: memoView.textView.text,
                        visitDate: visitTextField.attributedText?.string.toFormattedDateString() ?? "",
                        placeName: model.placeName,
                        address: model.addressName,
                        roadAddress: model.roadAddressName,
                        imageURLs: [],
                        latitude: model.latitude,
                        longitude: model.longitude,
                        categoryGroupCode: model.categoryGroupCode
                    ),
                    imageData: listener.imageArray.value.compactMap { $0.resizedImageWithinKilobytes() }
                )
            })
            .disposed(by: disposeBag)
    }
}

extension RegistLocationViewController: LocationImageCellDelegate {
    func deleteButtonTapped(inCell cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let listener = self.listener else { return }
        let newData = listener.imageArray.value
            .enumerated()
            .filter { index, _ in index != indexPath.row }
            .map { $0.1 }
        self.listener?.imageArray.accept(newData)
        self.addPhotoButton.updatePhoto(count: listener.imageArray.value.count)
    }
}

extension RegistLocationViewController: RegistLocationPresentable {
    func updateView(with data: KakaoSearchDocumentsModel) {
        addLocationTextField.attributedText = .makeAttributedString(
            text: "장소 이름 / \(data.placeName)",
            font: .title15RG,
            textColor: .textDefault,
            lineHeight: 24
        )
        addLocationImageView.image = .Icon.change
        listener?.isSelectLocation.accept(true)
    }
}
