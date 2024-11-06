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
    func updateProfile(nickname: String, imageData: Data?, completion: @escaping () -> Void)
    func popToProfileView()
    func sendTermsAgreement(agreements: [TermsAgreement])
    func viewDidAppear()
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

    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .Core.dimmed20
        view.alpha = 0
        return view
    }()

    private let bottomView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let bottomSubView: UIView = .init()

    private let bottomTitleLabel: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "서비스 이용약관을 확인해주세요",
            font: .title20XBD,
            textColor: .textDefault,
            lineHeight: 28
        )
        return label
    }()

    private let allAgreeButton: SelectButton = {
        let button: SelectButton = .init()
        button.setAttributedTitle(
            .makeAttributedString(
                text: "약관 전체동의",
                font: .title16XBD,
                textColor: .textDefault,
                lineHeight: 24
            ),
            for: .normal
        )
        return button
    }()

    private let grayView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .lineLight
        return view
    }()

    private lazy var termsStackView: UIStackView = {
        let view: UIStackView = .init()
        view.axis = .vertical
        view.spacing = 8
        view.addArrangedSubviews(serviceAgreeButton, privacyAgreeButton, marketingAgreeButton)
        return view
    }()

    private let serviceAgreeButton: SelectTermsView = {
        let button: SelectTermsView = .init()
        button.setTitle(title: "(필수) 서비스 이용약관 동의")
        return button
    }()

    private let privacyAgreeButton: SelectTermsView = {
        let button: SelectTermsView = .init()
        button.setTitle(title: "(필수) 개인정보 수집 및 이용약관동의")
        return button
    }()

    private let marketingAgreeButton: SelectTermsView = {
        let button: SelectTermsView = .init()
        button.setTitle(title: "(선택) 마케팅 정보 수신 동의")
        return button
    }()

    private let confirmButton: UIButton = {
        let button: UIButton = .init()
        button.setAttributedTitle(
            .makeAttributedString(
                text: "확인",
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listener?.viewDidAppear()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ProfileViewController {
    private func setupUI() {
        self.view.backgroundColor = .white

        self.view.addSubviews(self.customNavigationBar, self.subView, self.completeButton, self.dimmedView, self.bottomView)
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

        self.subView.addSubviews(
            self.titleLabel,
            self.profileImageView,
            self.nicknameLabel,
            self.nicknameInputView,
            self.existResultLabel
        )
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

        self.dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.bottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(430)
            $0.bottom.equalTo(view.snp.bottom).offset(430)
        }
        self.bottomView.addSubview(self.bottomSubView)
        self.bottomSubView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.trailing.bottom.equalToSuperview().inset(24)
        }
        self.bottomSubView.addSubviews(self.bottomTitleLabel, self.allAgreeButton, self.grayView, self.termsStackView, self.confirmButton)
        self.bottomTitleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.allAgreeButton.snp.makeConstraints {
            $0.top.equalTo(self.bottomTitleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview()
        }
        self.grayView.snp.makeConstraints {
            $0.top.equalTo(self.allAgreeButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        self.termsStackView.snp.makeConstraints {
            $0.top.equalTo(self.grayView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        self.confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(56)
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

        let serviceSelected = self.serviceAgreeButton.selectButton.rx.controlEvent(.touchUpInside)
            .map { [weak self] in
                guard let self else { return false }
                return self.serviceAgreeButton.isSelected
            }
            .share()
        let privacySelected = self.privacyAgreeButton.selectButton.rx.controlEvent(.touchUpInside)
            .map { [weak self] in
                guard let self else { return false }
                return self.privacyAgreeButton.isSelected
            }
            .share()
        let marketingSelected = self.marketingAgreeButton.selectButton.rx.controlEvent(.touchUpInside)
            .map { [weak self] in
                guard let self else { return false }
                return self.marketingAgreeButton.isSelected
            }
        Observable.combineLatest(serviceSelected, privacySelected, marketingSelected)
            .map { $0 && $1 && $2 }
            .bind(to: self.allAgreeButton.rx.isSelected)
            .disposed(by: disposeBag)

        Observable.combineLatest(serviceSelected, privacySelected)
            .map { $0 && $1 }
            .debug()
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self else { return }
                if isEnabled {
                    self.confirmButton.backgroundColor = .Core.primary
                    self.confirmButton.isEnabled = true
                } else {
                    self.confirmButton.backgroundColor = .Core.primaryDisabled
                    self.confirmButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        self.customNavigationBar.backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.popToProfileView()
            })
            .disposed(by: self.disposeBag)

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
                      let nickname = nicknameInputView.textField.text else {
                    return
                }
                let imageData = profileImageView.image?.resizedImageWithinKilobytes()
                self.listener?.updateProfile(nickname: nickname, imageData: imageData) { [weak self] in
                    guard let self else { return }
                    self.showBottomView()
                }
            })
            .disposed(by: self.disposeBag)

        self.allAgreeButton.rx.tap
            .map { [weak self] () -> Bool in
                guard let self else { return false }
                return self.allAgreeButton.isSelected
            }
            .subscribe(onNext: { [weak self] isSelected in
                guard let self else { return }
                if self.serviceAgreeButton.isSelected != isSelected {
                    self.serviceAgreeButton.selectButton.sendActions(for: .touchUpInside)
                }
                if self.privacyAgreeButton.isSelected != isSelected {
                    self.privacyAgreeButton.selectButton.sendActions(for: .touchUpInside)
                }
                if self.marketingAgreeButton.isSelected != isSelected {
                    self.marketingAgreeButton.selectButton.sendActions(for: .touchUpInside)
                }
            })
            .disposed(by: disposeBag)

        self.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                listener?.sendTermsAgreement(agreements: [
                    TermsAgreement(agreementType: .service, isAgreed: self.serviceAgreeButton.isSelected),
                    TermsAgreement(agreementType: .privacy, isAgreed: self.privacyAgreeButton.isSelected),
                    TermsAgreement(agreementType: .marketing, isAgreed: self.marketingAgreeButton.isSelected)
                ])
            })
            .disposed(by: disposeBag)
    }

    func showBottomViewIfNeeded(isProfileRequired: Bool) {
        if !isProfileRequired {
            self.showBottomView()
        }
    }

    private func showBottomView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.bottomView.snp.updateConstraints {
                $0.bottom.equalTo(self.view.snp.bottom).offset(0)
            }
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.dimmedView.alpha = 1
        })
    }
}
