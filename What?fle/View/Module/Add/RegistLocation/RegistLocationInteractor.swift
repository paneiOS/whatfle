//
//  RegistLocationInteractor.swift
//  What?fle
//
//  Created by 이정환 on 3/5/24.
//

import RIBs
import Moya
import RxSwift
import RxCocoa
import UIKit

protocol RegistLocationRouting: ViewableRouting {
    func routeToSelectLocation()
    func closeSelectLocation()
    func showCustomAlbum()
    func closeCustomAlbum()
}

protocol RegistLocationPresentable: Presentable {
    var listener: RegistLocationPresentableListener? { get set }
    func updateView(with data: KakaoSearchDocumentsModel)
}

protocol RegistLocationListener: AnyObject {
    func closeRegistLocation()
    func completeRegistLocation()
}

final class RegistLocationInteractor: PresentableInteractor<RegistLocationPresentable>,
                                      RegistLocationInteractable,
                                      RegistLocationPresentableListener {

    weak var router: RegistLocationRouting?
    weak var listener: RegistLocationListener?

    private let locationUseCase: LocationUseCaseProtocol
    private let disposeBag = DisposeBag()

    let accountID: Int?
    var model: KakaoSearchDocumentsModel?
    let imageArray = BehaviorRelay<[UIImage]>(value: [])
    let isSelectLocation = BehaviorRelay<Bool>(value: false)

    deinit {
        print("\(self) is being deinit")
    }

    init(
        presenter: RegistLocationPresentable,
        locationUseCase: LocationUseCaseProtocol,
        accountID: Int?
    ) {
        self.locationUseCase = locationUseCase
        self.accountID = accountID
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func showSelectLocation() {
        router?.routeToSelectLocation()
    }

    func closeSelectLocation() {
        router?.closeSelectLocation()
    }

    func showCustomAlbum() {
        router?.showCustomAlbum()
    }

    func closeCustomAlbum() {
        router?.closeCustomAlbum()
    }

    func addPhotos(images: [UIImage]) {
        let currentImages = imageArray.value + images
        imageArray.accept(currentImages)
        router?.closeCustomAlbum()
    }

    func registPlace(_ registration: PlaceRegistration, imageData: [Data]) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()
        self.locationUseCase.registPlace(registration: registration, imageData: imageData)
            .subscribe(onSuccess: { [weak self] _ in
                guard let self else { return }
                self.completeRegistLocation()
            }, onFailure: { error in
                print("\(self) Error:", error)
            }, onDisposed: {
                LoadingIndicatorService.shared.hideLoading()
            })
            .disposed(by: disposeBag)
    }
}

extension RegistLocationInteractor: RegistLocationListener {
    func closeRegistLocation() {
        listener?.closeRegistLocation()
    }

    func completeRegistLocation() {
        listener?.completeRegistLocation()
    }
}

extension RegistLocationInteractor: SelectLocationListener {
    func didSelect(data: KakaoSearchDocumentsModel) {
        closeSelectLocation()
        self.model = data
        presenter.updateView(with: data)
    }
}
