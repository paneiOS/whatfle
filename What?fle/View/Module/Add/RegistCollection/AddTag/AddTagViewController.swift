//
//  AddTagViewController.swift
//  What?fle
//
//  Created by 이정환 on 7/8/24.
//

import RIBs
import RxCocoa
import RxSwift
import SnapKit
import UIKit

protocol AddTagPresentableListener: AnyObject {
    var tags: BehaviorRelay<[TagType]> { get }
    func buttonTapped(index: Int)
    func addTag(type: TagType)
    func removeTag(index: Int)
    func closeAddTagView()
    func confirmTags(tags: [TagType])
}

final class AddTagViewController: UIVCWithKeyboard, AddTagPresentable, AddTagViewControllable {
//    private let dimmedView: UIView = {
//        let view: UIView = .init()
//        view.backgroundColor = .Core.dimmed20
//        view.isHidden = true
//        return view
//    }()

    private let contentsView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let closeButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.Icon.xLineLg, for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "태그 직접 입력",
            font: .title20XBD,
            textColor: .textDefault,
            lineHeight: 28
        )
        return label
    }()

    private let registView: UIView = .init()

    private lazy var registTextField: TextFieldWithErrorUnderline = {
        let textField: TextFieldWithErrorUnderline = .init()
        textField.attributedPlaceholder = .makeAttributedString(
            text: "태그 예시 문구",
            font: .body14MD,
            textColor: .textExtralight,
            lineHeight: 20
        )
        textField.clearButtonMode = .whileEditing
        textField.delegate = textField
        return textField
    }()

    private let underLine: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .textExtralight
        return view
    }()

    private let registButton: UIButton = {
        let button: UIButton = .init()
        button.backgroundColor = .Core.primaryDisabled
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.setAttributedTitle(
            .makeAttributedString(
                text: "추가",
                font: .title16MD,
                textColor: .white,
                lineHeight: 24
            ),
            for: .normal
        )
        return button
    }()

    private let registTagDescriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "(한글, 영어, 숫자 2~10자 이내로 입력해주세요.)",
            font: .caption13MD,
            textColor: .textExtralight,
            lineHeight: 20
        )
        return label
    }()

    private let registedView: UIView = .init()

    private let registedTagLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "등록한 태그",
            font: .caption12BD,
            textColor: .textExtralight,
            lineHeight: 20
        )
        return label
    }()

    private let registedTagCount: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "0/5",
            font: .caption12RG,
            textColor: .textExtralight,
            lineHeight: 20
        )
        return label
    }()

    private lazy var tagCollectionView: TagCollectionView = {
        let collectionView: TagCollectionView = .init()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private let confirmButton: UIButton = {
        let button: UIButton = .init()
        button.backgroundColor = .Core.primary
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.setAttributedTitle(
            .makeAttributedString(
                text: "등록",
                font: .title16MD,
                textColor: .textDefault,
                lineHeight: 24
            ),
            for: .normal
        )
        return button
    }()

    weak var listener: AddTagPresentableListener?
    private var tags: [TagType] = []
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewBinding()
        setupAction()
    }
}

extension AddTagViewController {
    private func setupUI() {
        view.backgroundColor = .clear

        self.view.addSubview(contentsView)
        contentsView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(430)
        }

        self.contentsView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().inset(24)
        }

        self.contentsView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.trailing.equalToSuperview().inset(24)
        }

        self.contentsView.addSubview(registView)
        registView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }

        self.registView.addSubview(registTextField)
        registTextField.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }

        self.registView.addSubview(registButton)
        registButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(registTextField.snp.trailing).offset(8)
            $0.width.equalTo(104)
        }

        self.contentsView.addSubview(registTagDescriptionLabel)
        registTagDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(registView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        self.contentsView.addSubview(registedView)
        registedView.snp.makeConstraints {
            $0.top.equalTo(registView.snp.bottom).offset(68)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        self.registedView.addSubview(registedTagLabel)
        registedTagLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        self.registedView.addSubview(registedTagCount)
        registedTagCount.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(registedTagLabel.snp.trailing).offset(8)
        }
        self.registedView.addSubview(tagCollectionView)
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(registedTagLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.contentsView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(registedView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
    }

    private func setupAction() {
        self.registTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    private func setupViewBinding() {
        listener?.tags
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tags in
                guard let self else { return }
                self.tags = tags
                self.registedTagCount.attributedText = .makeAttributedString(
                    text: "\(tags.count)/5",
                    font: .caption12RG,
                    textColor: tags.count == 5 ? .Core.warning : .textExtralight,
                    lineHeight: 20
                )
                self.tagCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        registTextField.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                if text.isValidLength(to: 2, from: 10), text.isValidRegistTag() {
                    self.registButton.backgroundColor = .GrayScale.black
                    self.registButton.isEnabled = true
                } else {
                    self.registButton.backgroundColor = .Core.primaryDisabled
                    self.registButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.listener?.closeAddTagView()
            })
            .disposed(by: disposeBag)

        registButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let tagStr = registTextField.text else { return }
                self.listener?.addTag(type: .addedSelectedButton(tagStr))
                self.registTextField.text = ""
            })
            .disposed(by: disposeBag)

        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.confirmTags(tags: self.tags)
            })
            .disposed(by: disposeBag)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        textField.attributedText = .makeAttributedString(
            text: text,
            font: .body14MD,
            textColor: .textDefault,
            lineHeight: 20
        )
    }
}

extension AddTagViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell,
              let cellType = self.tags[safe: indexPath.row] else { return UICollectionViewCell() }
        cell.delegate = self
        cell.drawCell(cellType: cellType)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellType = tags[safe: indexPath.item] else { return .zero }
        return CGSize(width: cellType.width, height: cellType.height)
    }
}

extension AddTagViewController: TagCellDelegate {
    func didTapCloseButton(in cell: TagCell) {
        if let indexPath = tagCollectionView.indexPath(for: cell) {
            listener?.removeTag(index: indexPath.item)
        }
    }
}
