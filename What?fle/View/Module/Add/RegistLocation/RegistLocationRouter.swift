//
//  RegistLocationRouter.swift
//  What?fle
//
//  Created by 이정환 on 3/5/24.
//

import RIBs

protocol RegistLocationInteractable: Interactable, SelectLocationListener, CustomAlbumListener {
    var router: RegistLocationRouting? { get set }
    var listener: RegistLocationListener? { get set }
}

protocol RegistLocationViewControllable: ViewControllable {}

final class RegistLocationRouter: ViewableRouter<RegistLocationInteractable, RegistLocationViewControllable> {
    private let component: RegistLocationComponent

    private weak var selectLocationRouter: SelectLocationRouting?
    private weak var customAlbumRouter: CustomAlbumRouting?

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: RegistLocationInteractable,
        viewController: RegistLocationViewControllable,
        component: RegistLocationComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension RegistLocationRouter: RegistLocationRouting {
    func routeToSelectLocation() {
        if self.selectLocationRouter == nil {
            let router = self.component.selectLocationBuilder.build(withListener: self.interactor)
            router.viewControllable.setPresentationStyle(style: .overFullScreen)
            self.viewController.present(router.viewControllable, animated: true)
            self.attachChild(router)
            self.selectLocationRouter = router
        }
    }

    func closeSelectLocation() {
        if let selectLocationRouter {
            selectLocationRouter.viewControllable.uiviewController.dismiss(animated: true) { [weak self] in
                guard let self else { return }
                self.detachChild(selectLocationRouter)
                self.selectLocationRouter = nil
            }
        }
    }

    func showCustomAlbum() {
        if self.customAlbumRouter == nil {
            let router = self.component.customAlbumBuilder.buildMultiSelect(withListener: self.interactor)
            router.viewControllable.setPresentationStyle(style: .overFullScreen)
            self.viewController.present(router.viewControllable, animated: true)
            self.attachChild(router)
            self.customAlbumRouter = router
        }
    }

    func closeCustomAlbum() {
        if let customAlbumRouter {
            customAlbumRouter.viewControllable.uiviewController.dismiss(animated: true) { [weak self] in
                guard let self else { return }
                self.detachChild(customAlbumRouter)
                self.customAlbumRouter = nil
            }
        }
    }
}
