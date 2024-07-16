//
//  CustomAlbumViewController.swift
//  What?fle
//
//  Created by 이정환 on 7/16/24.
//

import RIBs
import RxSwift
import UIKit

protocol CustomAlbumPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class CustomAlbumViewController: UIViewController, CustomAlbumPresentable, CustomAlbumViewControllable {

    weak var listener: CustomAlbumPresentableListener?
}
