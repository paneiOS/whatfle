//
//  ProfileViewController.swift
//  What?fle
//
//  Created by JeongHwan Lee on 8/18/24.
//

import UIKit

import RIBs
import RxSwift
import RxCocoa

protocol ProfilePresentableListener: AnyObject {
    var existNicknameState: PublishRelay<ProfileInteractor.ExistNicknameState> { get }
    var profileImage: PublishRelay<UIImage> { get }
    func existCheck(nickname: String)
    func showCustomAlbum()
    func updateProfile(nickname: String, imageData: Data)
    func popToProfileView()
}

final class ProfileViewController: UIViewController, ProfilePresentable, ProfileViewControllable {

    weak var listener: ProfilePresentableListener?

    private let customNavigationBar: CustomNavigationBar = {
        let view: CustomNavigationBar = .init()
        view.setNavigationTitle()
        return view
    }()

    private let subView: UIView = .init()

    private let titleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "프로필을 설정해주세요",
            font: .title24XBD,
            textColor: .textDefault,
            lineHeight: 32
        )
        return label
    }()

    private let profileImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        let cameraImage: UIImageView = .init(image: .Icon.cameraIcon)
        imageView.addSubview(cameraImage)
        imageView.backgroundColor = .Core.background
        cameraImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let addProfileControl: UIControl = .init()

    private let nicknameLabel: UILabel = {
        let label: UILabel = .init()
        let nicknameLabel: UILabel = {
            let label: UILabel = .init()
            label.attributedText = .makeAttributedString(
                text: "닉네임",
                font: .title15XBD,
                textColor: .textLight,
                lineHeight: 24
            )
            return label
        }()

        let nicknameRuleLabel: UILabel = {
            let label: UILabel = .init()
            label.attributedText = .makeAttributedString(
                text: "(한글, 영문 6자 이내)",
                font: .title15RG,
                textColor: .textExtralight,
                lineHeight: 24
            )
            return label
        }()
        label.addSubviews(nicknameLabel, nicknameRuleLabel)
        nicknameLabel.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        nicknameRuleLabel.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel.snp.trailing).offset(4)
            $0.top.bottom.trailing.equalToSuperview()
        }
        return label
    }()

    private lazy var nicknameInputView: TextFieldWithCheckView = {
        let view: TextFieldWithCheckView = .init()
        view.attributedPlaceholder = .makeAttributedString(
            text: "왓플메이커",
            font: .body14MD,
            textColor: .textExtralight,
            lineHeight: 20
        )
        view.attributedTitle = .makeAttributedString(
            text: "중복확인",
            font: .title16MD,
            textColor: .white,
            lineHeight: 24
        )
        return view
    }()

    private let existResultLabel: UILabel = .init()

    private let completeButton: UIButton = {
        let button: UIButton = .init()
        button.setAttributedTitle(
            .makeAttributedString(
                text: "완료",
                font: .title16MD,
                textColor: .GrayScale.white,
                lineHeight: 24
            ),
            for: .normal
        )
        button.backgroundColor = .Core.primaryDisabled
        button.isEnabled = false
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()

    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupViewBinding()
        self.setupActionBinding()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    private func setupUI() {
        self.view.backgroundColor = .white

        self.view.addSubviews(self.customNavigationBar, self.subView, self.completeButton)
        self.customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        self.subView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBar.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        self.completeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.height.equalTo(56)
        }

        self.subView.addSubviews(self.titleLabel, self.profileImageView, self.nicknameLabel, self.nicknameInputView, self.existResultLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.profileImageView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(120)
        }
        self.profileImageView.addSubview(self.addProfileControl)
        self.addProfileControl.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
        }
        self.nicknameInputView.snp.makeConstraints {
            $0.top.equalTo(self.nicknameLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }
        self.existResultLabel.snp.makeConstraints {
            $0.top.equalTo(self.nicknameInputView.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }

    private func setupViewBinding() {
        self.nicknameInputView.textField.rx.text
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.listener?.existNicknameState.accept(.none)
                if text.isEmpty {
                    self.nicknameInputView.underlineColorSubject.onNext(.empty)
                } else if !text.isValidLength(to: 1, from: 6) || !text.isValidRegistTag() {
                    self.nicknameInputView.underlineColorSubject.onNext(.invalid)
                } else {
                    self.nicknameInputView.underlineColorSubject.onNext(.valid)
                }
            })
            .disposed(by: self.disposeBag)

        self.listener?.existNicknameState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard let self else { return }
                switch state {
                case .disable:
                    self.existResultLabel.attributedText =
                    .makeAttributedString(
                        text: "해당 닉네임을 사용하실 수 없습니다",
                        font: .caption13MD,
                        textColor: .Core.warning,
                        lineHeight: 20
                    )
                case .enable:
                    self.existResultLabel.attributedText = .makeAttributedString(
                        text: "해당 닉네임을 사용하실 수 있습니다",
                        font: .caption13MD,
                        textColor: .Core.approve,
                        lineHeight: 20
                    )
                case .none:
                    self.existResultLabel.text = ""
                }
            })
            .disposed(by: disposeBag)

        self.listener?.existNicknameState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard let self else { return }
                switch state {
                case .disable, .none:
                    self.completeButton.setAttributedTitle(
                        .makeAttributedString(
                            text: "완료",
                            font: .title16MD,
                            textColor: .GrayScale.white,
                            lineHeight: 24
                        ),
                        for: .normal
                    )
                    self.completeButton.backgroundColor = .Core.primaryDisabled
                    self.completeButton.isEnabled = false
                case .enable:
                    self.completeButton.setAttributedTitle(
                        .makeAttributedString(
                            text: "완료",
                            font: .title16MD,
                            textColor: .textDefault,
                            lineHeight: 24
                        ),
                        for: .normal
                    )
                    self.completeButton.backgroundColor = .Core.primary
                    self.completeButton.isEnabled = true
                }
            })
            .disposed(by: self.disposeBag)

        self.listener?.profileImage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                self.profileImageView.image = image
            })
            .disposed(by: self.disposeBag)
    }

    private func setupActionBinding() {
        self.addProfileControl.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.showCustomAlbum()
            })
            .disposed(by: self.disposeBag)

        self.nicknameInputView.registButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let nickname = self.nicknameInputView.textField.text else { return }
                self.nicknameInputView.endEditing(false)
                self.listener?.existCheck(nickname: nickname)
            })
            .disposed(by: disposeBag)

        self.completeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let nickname = nicknameInputView.textField.text,
                      let imageData = profileImageView.image?.resizedImageWithinKilobytes() else {
                    return
                }
                self.listener?.updateProfile(nickname: nickname, imageData: imageData)
            })
            .disposed(by: self.disposeBag)

        self.customNavigationBar.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.popToProfileView()
            })
            .disposed(by: self.disposeBag)
    }
}
