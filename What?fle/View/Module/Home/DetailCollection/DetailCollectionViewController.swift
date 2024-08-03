//
//  DetailCollectionViewController.swift
//  What?fle
//
//  Created by 이정환 on 8/1/24.
//

import RIBs
import RxSwift
import UIKit

protocol DetailCollectionPresentableListener: AnyObject {}

final class DetailCollectionViewController: UIViewController, DetailCollectionPresentable, DetailCollectionViewControllable {

    weak var listener: DetailCollectionPresentableListener?

    override func viewDidLoad() {
        self.view.backgroundColor = .blue
    }
}
