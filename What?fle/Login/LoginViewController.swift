//
//  LoginViewController.swift
//  What?fle
//
//  Created by 23 09 on 7/2/24.
//

import Alamofire
import KakaoSDKAuth
import KakaoSDKUser
import RIBs
import RxCocoa
import RxKakaoSDKCommon
import RxKakaoSDKUser
import RxSwift
import Supabase
import UIKit

protocol LoginPresentableListener: AnyObject {
    func loginWithKakao()
    func loginWithApple()
}

final class LoginViewController: UIViewController, LoginPresentable, LoginViewControllable {
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(.xLineLg, for: .normal)
        return button
    }()
    private let tutleView: UIView = .init()
    private let imageView: UIImageView = .init(image: .turfle)
    private let label: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "왓플 메이커가\n되어주세요!",
            font: .title32HV,
            textColor: .textDefault,
            lineHeight: 40,
            alignment: .center
        )
        label.numberOfLines = 2
        return label
    }()
    private let appleLoginButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "apple.logo")?.withRenderingMode(.alwaysTemplate)
        config.imagePadding = 8
        config.title = "애플로 로그인하기"
        config.baseForegroundColor = .white
        let button: UIButton = .init(configuration: config)
        button.layer.cornerRadius = 4
        button.backgroundColor = .black
        button.tintColor = .white
        button.titleLabel?.font = .title16MD
        return button
    }()
    private let kakaoLoginButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .kakao
        config.imagePadding = 8
        config.title = "카카오로 로그인하기"
        config.baseForegroundColor = .white
        let button: UIButton = .init(configuration: config)
        button.layer.cornerRadius = 4
        button.backgroundColor = .Core.primary
        button.titleLabel?.font = .title16MD
        return button
    }()
    private let nonMemberButton: UIButton = {
        let button: UIButton = .init()
        button.setTitle("비회원으로 둘러보기", for: .normal)
        button.titleLabel?.attributedText = .makeAttributedString(
            text: "비회원으로 둘러보기",
            font: .body14MD,
            textColor: .textExtralight,
            lineHeight: 20,
            alignment: .center
        )
        return button
    }()
    private let disposeBag = DisposeBag()
    weak var listener: LoginPresentableListener?

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.setupActionBinding()
    }
}

extension LoginViewController {
    private func setUI() {
        view.backgroundColor = .white

        view.addSubview(tutleView)
        tutleView.addSubview(label)
        tutleView.addSubview(imageView)
        tutleView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(138)
        }
        label.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(label.snp.top).offset(-40)
            $0.width.equalTo(186)
            $0.height.equalTo(145)
        }

        view.addSubview(appleLoginButton)
        appleLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(label.snp.bottom).offset(83)
            $0.height.equalTo(56)
            $0.width.equalTo(327)
        }

        view.addSubview(kakaoLoginButton)
        kakaoLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(8)
            $0.height.equalTo(56)
            $0.width.equalTo(327)
        }

        view.addSubview(nonMemberButton)
        nonMemberButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(16)
        }

        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalToSuperview().inset(29)
        }
    }

    private func setupActionBinding() {
        kakaoLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.loginWithKakao()
            })
            .disposed(by: disposeBag)

        appleLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.loginWithApple()
            })
            .disposed(by: disposeBag)
    }
}
