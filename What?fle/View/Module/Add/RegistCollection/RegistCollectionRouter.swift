//
//  RegistCollectionRouter.swift
//  What?fle
//
//  Created by 이정환 on 4/17/24.
//

import RIBs

protocol RegistCollectionInteractable: Interactable, AddCollectionListener, AddTagListener, CustomAlbumListener {
    var router: RegistCollectionRouting? { get set }
    var listener: RegistCollectionListener? { get set }
}

protocol RegistCollectionViewControllable: ViewControllable {}

final class RegistCollectionRouter: ViewableRouter<RegistCollectionInteractable, RegistCollectionViewControllable> {
    private let component: RegistCollectionComponent

    weak var addCollectionRouter: AddCollectionRouting?
    weak var addTagRouter: AddTagRouting?
    private weak var customAlbumRouter: CustomAlbumRouting?

    deinit {
        print("\(self) is being deinit")
    }

    init(
        interactor: RegistCollectionInteractable,
        viewController: RegistCollectionViewControllable,
        component: RegistCollectionComponent
    ) {
        self.component = component
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}

extension RegistCollectionRouter: RegistCollectionRouting {
    func closeAddCollection() {
        if let router = self.addCollectionRouter {
            self.viewController.uiviewController.dismiss(animated: true) {
                self.detachChild(router)
                self.addCollectionRouter = nil
            }
        }
    }

    func routeToAddCollection(data: EditSelectedCollectionData) {
        if self.addCollectionRouter == nil {
            let router = self.component.addCollectionBuilder.build(withListener: self.interactor, withData: data)
            router.viewControllable.uiviewController.modalPresentationStyle = .fullScreen
            self.viewControllable.uiviewController.present(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.addCollectionRouter = router
        }
    }

    func dismissAddCollection() {
        if let router = self.addCollectionRouter {
            self.viewController.uiviewController.dismiss(animated: true) {
                self.detachChild(router)
                self.addCollectionRouter = nil
            }
        }
    }

    func routeToAddTag(tags: [TagType]) {
        if self.addTagRouter == nil {
            let router = self.component.addTagBuilder.build(withListener: self.interactor, tags: tags)
            router.viewControllable.uiviewController.modalPresentationStyle = .overCurrentContext
            self.viewControllable.uiviewController.present(router.viewControllable.uiviewController, animated: true)
            self.attachChild(router)
            self.addTagRouter = router
        }
    }

    func closeAddTag() {
        if let router = self.addTagRouter {
            self.viewController.uiviewController.dismiss(animated: true) {
                self.detachChild(router)
                self.addTagRouter = nil
            }
        }
    }
}

extension RegistCollectionRouter: CustomAlbumRouting {
    func showCustomAlbum() {
        if self.customAlbumRouter == nil {
            let router = self.component.customAlbumBuilder.buildSingleSelect(withListener: self.interactor)
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
