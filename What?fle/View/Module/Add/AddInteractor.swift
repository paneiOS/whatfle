//
//  AddInteractor.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import RxSwift
import UIKit

protocol AddRouting: ViewableRouting {
    var navigationController: UINavigationController { get }
    func routeToRegistCollection(data: EditSelectedCollectionData, tags: [RecommendHashTagModel])
    func routeToAddCollection(data: EditSelectedCollectionData?)
    func popToAddCollection()
    func popToRegistCollection()
    func popToRegistLocation()
}

protocol AddPresentable: Presentable {
    var listener: AddPresentableListener? { get set }
}

protocol AddListener: AnyObject {
    func showRegistLocation()
    func closeAddRIB()
}

final class AddInteractor: PresentableInteractor<AddPresentable> {
    weak var router: AddRouting?
    weak var listener: AddListener?

    deinit {
        print("\(self) is being deinit")
    }

    override init(presenter: AddPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
}

extension AddInteractor: AddInteractable {
    func popToAddCollection() {
        self.router?.popToAddCollection()
    }

    func popToRegistCollection() {
        self.router?.popToRegistCollection()
    }

    func sendDataToRegistCollection(data: EditSelectedCollectionData, tags: [RecommendHashTagModel]) {
        self.router?.routeToRegistCollection(data: data, tags: tags)
    }

    func sendDataToAddCollection(data: EditSelectedCollectionData) {
        self.router?.routeToAddCollection(data: data)
    }

    func closeRegistLocation() {
        self.router?.popToRegistLocation()
    }

    func closeAddCollection() {
        self.router?.navigationController.popViewController(animated: true)
    }

    func dismissAddCollection() {}
}

extension AddInteractor: AddPresentableListener {
    func showRegistLocation() {
        listener?.showRegistLocation()
    }

    func completeRegistLocation() {
        listener?.closeAddRIB()
    }

    func closeView() {
        listener?.closeAddRIB()
    }

    func showAddCollection() {
        router?.routeToAddCollection(data: nil)
    }

    func completeRegistCollection() {
        listener?.closeAddRIB()
    }
}
