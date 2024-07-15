//
//  RegistCollectionInteractor.swift
//  What?fle
//
//  Created by 이정환 on 4/17/24.
//

import Moya
import RIBs
import RxSwift
import RxCocoa
import UIKit

protocol RegistCollectionRouting: ViewableRouting {
    func routeToRegistCollection(data: EditSelectedCollectionData)
    func routeToAddTag(tags: [TagType])
    func closeCurrentRIB()
    func confirmTags(tags: [TagType])
}

protocol RegistCollectionPresentable: Presentable {
    var listener: RegistCollectionPresentableListener? { get set }
}

protocol RegistCollectionListener: AnyObject {
    func popToCurrentRIB()
    func completeRegistCollection()
}

final class RegistCollectionInteractor: PresentableInteractor<RegistCollectionPresentable>,
                                        RegistCollectionInteractable,
                                        RegistCollectionPresentableListener {
    weak var router: RegistCollectionRouting?
    weak var listener: RegistCollectionListener?

    var selectedImage: BehaviorRelay<UIImage?> = .init(value: nil)
    var tags: BehaviorRelay<[TagType]>
    var isHiddenDimmedView: BehaviorRelay<Bool> = .init(value: true)
    let selectedLocations: BehaviorRelay<[PlaceRegistration]>
    var editSelectedCollectionData: EditSelectedCollectionData

    private let networkService: NetworkServiceDelegate
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(
        presenter: RegistCollectionPresentable,
        networkService: NetworkServiceDelegate,
        data: EditSelectedCollectionData,
        tags: [RecommendHashTagModel]
    ) {
        self.networkService = networkService
        self.editSelectedCollectionData = data
        self.tags = .init(value: tags.map { .deselected(.init(id: $0.id, hashtagName: $0.hashtagName)) })
        self.selectedLocations = .init(value: data.map { $0.1 })
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func buttonTapped(index: Int) {
        var currentTags: [TagType] = tags.value
        if let tag = currentTags[safe: index]?.toggle() {
            currentTags[index] = tag
            tags.accept(currentTags)
        }
    }

    func addImage(_ image: UIImage) {
        self.selectedImage.accept(image)
    }

    func removeImage() {
        self.selectedImage.accept(nil)
    }

    func removeTag(index: Int) {
        var currentTags: [TagType] = tags.value
        currentTags.remove(at: index)
        tags.accept(currentTags)
    }

    func showEditCollection() {
        self.router?.routeToRegistCollection(data: editSelectedCollectionData)
    }

    func showAddTagRIB(tags: [TagType]) {
        let filteredTags = tags.filter {
            if case .addedSelectedButton = $0 {
                return true
            } else {
                return false
            }
        }
        self.router?.routeToAddTag(tags: filteredTags)
    }

    func closeAddTagView() {
        self.isHiddenDimmedView.accept(true)
        self.router?.closeCurrentRIB()
    }

    func confirmTags(tags: [TagType]) {
        var currentTags: [TagType] = self.tags.value
        let addedTags = tags.filter { !currentTags.contains($0) }
        currentTags.append(contentsOf: addedTags)
        self.tags.accept(currentTags)
        self.closeAddTagView()
    }

    func popToCurrentRIB() {
        self.listener?.popToCurrentRIB()
    }

    func registCollection(data: CollectionData ) {
        guard !LoadingIndicatorService.shared.isLoading() else { return }
        LoadingIndicatorService.shared.showLoading()
        uploadPlaceImages(image: selectedImage.value)
            .flatMap { [weak self] imageURLs -> Single<Response> in
                guard let self = self else { return .error(RxError.unknown) }
                return self.networkService.request(WhatfleAPI.registCollectionData(.init(data: data, imageURls: imageURLs)))
            }
            .subscribe(onSuccess: { [weak self] _ in
                guard let self else { return }
                LoadingIndicatorService.shared.hideLoading()
                self.listener?.completeRegistCollection()
            }, onFailure: { error in
                LoadingIndicatorService.shared.hideLoading()
                if let error = error as? CustomError {
                    print("Error in registration process: \(error.localizedDescription)")
                } else {
                    print("Unknown error occurred")
                }
            })
            .disposed(by: disposeBag)
    }

    private func uploadPlaceImages(image: UIImage?) -> Single<[String]> {
        guard let image else {
            return Single.just([])
        }
        return networkService.request(WhatfleAPI.uploadPlaceImage(images: [image]))
            .map { response -> [String] in
                return try JSONDecoder().decode([String].self, from: response.data)
            }
    }

    func sendDataToRegistCollection(data: EditSelectedCollectionData, tags: [RecommendHashTagModel]) {}

    func closeAddCollection() {}
}
