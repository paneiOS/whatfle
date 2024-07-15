//
//  RegistCollectionRouter.swift
//  What?fle
//
//  Created by 이정환 on 4/17/24.
//

import RIBs

protocol RegistCollectionInteractable: Interactable, AddCollectionListener, AddTagListener {
    var router: RegistCollectionRouting? { get set }
    var listener: RegistCollectionListener? { get set }
}

protocol RegistCollectionViewControllable: ViewControllable {}

final class RegistCollectionRouter: ViewableRouter<RegistCollectionInteractable, RegistCollectionViewControllable> {
    private let component: RegistCollectionComponent
    private weak var currentChild: ViewableRouting?

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
    func closeAddTag() {
        self.closeCurrentRIB()
    }

    func closeAddCollection() {
        if let currentChild = self.currentChild {
            self.viewController.uiviewController.dismiss(animated: true) {
                self.detachChild(currentChild)
            }
        }
    }

    func routeToRegistCollection(data: EditSelectedCollectionData) {
        let router = self.component.addCollectionBuilder.build(withListener: self.interactor, withData: data)
        router.viewControllable.uiviewController.modalPresentationStyle = .fullScreen
        self.viewControllable.uiviewController.present(router.viewControllable.uiviewController, animated: true)
        self.attachChild(router)
        self.currentChild = router
    }

    func closeCurrentRIB() {
        if let currentChild = self.currentChild {
            self.viewController.uiviewController.dismiss(animated: true) {
                self.detachChild(currentChild)
            }
        }
    }

    func routeToAddTag(tags: [TagType]) {
        let router = self.component.addTagBuilder.build(withListener: self.interactor, tags: tags)
        router.viewControllable.uiviewController.modalPresentationStyle = .overCurrentContext
        self.viewControllable.uiviewController.present(router.viewControllable.uiviewController, animated: true)
        self.attachChild(router)
        self.currentChild = router
    }

    func confirmTags(tags: [TagType]) {}
}
