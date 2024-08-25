//
//  SplashViewController.swift
//  What?fle
//
//  Created by 이정환 on 4/10/24.
//

import RIBs
import RxSwift
import UIKit

protocol SplashPresentableListener: AnyObject {}

final class SplashViewController: UIViewController, SplashPresentable, SplashViewControllable {

    weak var listener: SplashPresentableListener?

    private let tutleView: UIView = .init()
    private let imageView: UIImageView = .init(image: .turfle)
    private let label: UILabel = {
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "WHATFLE",
            font: .title32HV,
            textColor: .textDefault,
            lineHeight: 40,
            alignment: .center
        )
        return label
    }()

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    private func setupUI() {
        view.addSubview(tutleView)
        tutleView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        tutleView.addSubviews(label, imageView)
        label.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(label.snp.top).offset(-33)
            $0.width.equalTo(186)
            $0.height.equalTo(145)
        }

        addGradientBackground()
    }

    private func addGradientBackground() {
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        CAGradientLayer.GradientType.allCases.forEach {
            let gradientLayer = CAGradientLayer.createGradient(type: $0)
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: UInt32($0.rawValue))
        }
    }
}
