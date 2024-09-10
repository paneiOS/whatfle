//
//  HomeRouter.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import UIKit

protocol HomeInteractable: Interactable {
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }
}

protocol HomeViewControllable: ViewControllable {}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable> {
    private let component: HomeComponent
    let navigationController: UINavigationController

    weak var loginRouter: LoginRouting?
    weak var detailCollectionRouter: DetailCollectionRouting?

    var isLogin: Bool {
        component.networkService.isLogin
    }

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: HomeInteractable,
        viewController: HomeViewControllable,
        navigationController: UINavigationController,
        component: HomeComponent
    ) {
        self.component = component
        self.navigationController = navigationController
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension HomeRouter: HomeRouting {}
