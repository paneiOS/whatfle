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
    private let networkService: NetworkServiceDelegate
    private let disposeBag = DisposeBag()

    var model: KakaoSearchDocumentsModel?
    let imageArray = BehaviorRelay<[UIImage]>(value: [])
    let isSelectLocation = BehaviorRelay<Bool>(value: false)

    deinit {
        print("\(self) is being deinit")
    }

    init(presenter: RegistLocationPresentable, networkService: NetworkServiceDelegate) {
        self.networkService = networkService
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

    func registPlace(_ registration: PlaceRegistration) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()
        uploadPlaceImages(images: registration.images)
            .flatMap { [weak self] imageURLs -> Single<Response> in
                guard let self = self else { return .error(RxError.unknown) }
                return self.networkService.request(WhatfleAPI.registerPlace(.init(imageURLs: imageURLs, registration: registration)))
            }
            .subscribe(onSuccess: { [weak self] _ in
                guard let self else { return }
                LoadingIndicatorService.shared.hideLoading()
                self.completeRegistLocation()
            }, onFailure: { error in
                LoadingIndicatorService.shared.hideLoading()
                if let error = error as? CustomError {
                    print("Error in registration process: \(error.localizedDescription)")
                } else {
                    print("Unknown error occurred", error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }

    private func uploadPlaceImages(images: [UIImage]) -> Single<[String]> {
        guard !images.isEmpty else {
            return Single.just([])
        }
        return networkService.request(WhatfleAPI.uploadPlaceImage(images: images))
            .map { response -> [String] in
                return try JSONDecoder().decode([String].self, from: response.data)
            }
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
