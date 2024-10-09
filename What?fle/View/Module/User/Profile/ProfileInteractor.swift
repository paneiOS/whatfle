//
//  ProfileInteractor.swift
//  What?fle
//
//  Created by JeongHwan Lee on 8/18/24.
//

import UIKit

import RIBs
import RxSwift
import RxCocoa

protocol ProfileRouting: ViewableRouting {
    func showCustomAlbum()
    func closeCustomAlbum()
}

protocol ProfilePresentable: Presentable {
    var listener: ProfilePresentableListener? { get set }
    func showBottomViewIfNeeded(isProfileRequired: Bool)
}

protocol ProfileListener: AnyObject {
    func popToProfileView()
    func closeLogin()
}

final class ProfileInteractor: PresentableInteractor<ProfilePresentable>, ProfileInteractable, ProfilePresentableListener {

    enum ExistNicknameState {
        case enable
        case disable
        case none
    }

    weak var router: ProfileRouting?
    weak var listener: ProfileListener?

    private let loginUseCase: LoginUseCaseProtocol
    private let disposeBag = DisposeBag()

    let isProfileRequired: Bool
    var profileImage: PublishRelay<UIImage> = .init()
    var existNicknameState: PublishRelay<ExistNicknameState> = .init()

    init(
        presenter: ProfilePresentable,
        loginUseCase: LoginUseCaseProtocol,
        isProfileRequired: Bool
    ) {
        self.loginUseCase = loginUseCase
        self.isProfileRequired = isProfileRequired
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func existCheck(nickname: String) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        loginUseCase.existNickname(nickname: nickname)
            .subscribe(onSuccess: { [weak self] isExisted in
                guard let self else { return }
                let isExisted = isExisted ? ExistNicknameState.disable : ExistNicknameState.enable
                self.existNicknameState.accept(isExisted)
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }

    func showCustomAlbum() {
        router?.showCustomAlbum()
    }

    func closeCustomAlbum() {
        router?.closeCustomAlbum()
    }

    func addPhotos(images: [UIImage]) {
        guard let image = images.first else { return }
        profileImage.accept(image)
        router?.closeCustomAlbum()
    }

    func updateProfile(nickname: String, imageData: Data?, completion: @escaping () -> Void) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        loginUseCase.updateUserProfile(nickname: nickname, imageData: imageData)
            .subscribe(onSuccess: {
                completion()
            }, onFailure: { error in
                errorPrint(error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }

    func sendTermsAgreement(agreements: [TermsAgreement]) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()

        loginUseCase.sendTermsAgreement(agreements: agreements)
            .subscribe(onSuccess: { [weak self] _ in
                guard let self else { return }
                self.listener?.closeLogin()
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }

    func popToProfileView() {
        listener?.popToProfileView()
    }

    func viewDidAppear() {
        self.presenter.showBottomViewIfNeeded(isProfileRequired: isProfileRequired)
    }
}
