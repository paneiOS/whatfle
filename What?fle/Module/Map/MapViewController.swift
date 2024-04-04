//
//  MapViewController.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import RIBs
import RxSwift
import UIKit

protocol MapPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class MapViewController: UIViewController, MapPresentable, MapViewControllable {

    weak var listener: MapPresentableListener?
}
