//
//  LoginViewController.swift
//  What?fle
//
//  Created by 이정환 on 8/15/24.
//

import AuthenticationServices
import RIBs
import RxSwift
import UIKit

protocol LoginPresentableListener: AnyObject {
    func appleLogin(idToken: String)
}

final class LoginViewController: UIViewController, LoginPresentable, LoginViewControllable {

    weak var listener: LoginPresentableListener?
    private let disposeBag = DisposeBag()

    private lazy var customNavigationBar: CustomNavigationBar = {
        let view: CustomNavigationBar = .init()
        view.setRightButton(image: .xLineLg)
        return view
    }()

    private let subView: UIView = .init()

    private let descriptionView: UIView = .init()

    private let imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.backgroundColor = .init(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 2
        label.attributedText = .makeAttributedString(
            text: "왓플 메이커가\n되어주세요!",
            font: .title32HV,
            textColor: .textDefault,
            lineHeight: 40,
            alignment: .center
        )
        return label
    }()

    private let loginViews: UIView = .init()

    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

    private let noMemberButton: UIButton = {
        let button: UIButton = .init()
        button.setAttributedTitle(
            .makeAttributedString(
                text: "비회원으로 둘러보기",
                font: .body14MD,
                textColor: .textExtralight,
                lineHeight: 20
            ),
            for: .normal
        )
        button.isUserInteractionEnabled = true
        return button
    }()

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupActionBinding()
    }

    private func setupUI() {
        view.backgroundColor = .white

        [self.customNavigationBar, self.subView].forEach {
            view.addSubview($0)
        }

        self.customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }

        subView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        [self.descriptionView, self.loginViews].forEach {
            subView.addSubview($0)
        }
        self.descriptionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        [self.imageView, self.descriptionLabel].forEach {
            self.descriptionView.addSubview($0)
        }
        self.imageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.size.equalTo(200)
        }
        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom).offset(40)
            $0.centerX.bottom.equalToSuperview()
        }
        self.loginViews.snp.makeConstraints {
            $0.top.equalTo(descriptionView.snp.bottom).offset(80)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        [self.appleLoginButton, noMemberButton].forEach {
            self.loginViews.addSubview($0)
        }
        self.appleLoginButton.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.equalTo(327)
            $0.height.equalTo(56)
        }
        self.noMemberButton.snp.makeConstraints {
            $0.top.equalTo(self.appleLoginButton.snp.bottom).offset(16)
            $0.centerX.bottom.equalToSuperview()
        }
    }

    private func setupActionBinding() {
        self.customNavigationBar.rightButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: {
                
            })
            .disposed(by: disposeBag)

        self.appleLoginButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName, .email]
                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self
                authorizationController.presentationContextProvider = self
                authorizationController.performRequests()
            })
            .disposed(by: disposeBag)

        self.noMemberButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: {
                
            })
            .disposed(by: disposeBag)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) else {
            return
        }
        listener?.appleLogin(idToken: idTokenString)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign In Failed: \(error.localizedDescription)")
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
