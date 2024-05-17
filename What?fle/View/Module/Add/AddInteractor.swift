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
    func routeToRegistLocation()
    func routeToRegistCollection(data: EditSelectedCollectionData)
    func routeToAddCollection(data: EditSelectedCollectionData?)
    func closeCurrentRIB()
}

protocol AddPresentable: Presentable {
    var listener: AddPresentableListener? { get set }
}

protocol AddListener: AnyObject {
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
    func popCurrentRIB() {
        listener?.closeAddRIB()
    }

    func sendDataToRegistCollection(data: EditSelectedCollectionData) {
        router?.routeToRegistCollection(data: data)
    }

    func sendDataToAddCollection(data: EditSelectedCollectionData) {
        router?.routeToAddCollection(data: data)
    }

    func closeRegistLocation() {
        self.router?.navigationController.popViewController(animated: true)
        router?.closeCurrentRIB()
    }

    func completeRegistLocation() {
        closeRegistLocation()
        popCurrentRIB()
    }

    func closeAddCollection() {
        router?.closeCurrentRIB()
    }
}

extension AddInteractor: AddPresentableListener {
    func showRegistLocation() {
        router?.routeToRegistLocation()
    }

    func showAddCollection() {
        router?.routeToAddCollection(data: nil)
    }

    func closeView() {
        listener?.closeAddRIB()
    }
}
