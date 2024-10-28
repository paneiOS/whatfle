//
//  DetailImageView.swift
//  What?fle
//
//  Created by 이정환 on 10/28/24.
//

import UIKit

import SnapKit

final class DetailImageView: UIView {
    private let backgroundView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .black
        return view
    }()

    private let imageView: UIImageView = {
        let view: UIImageView = .init()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button: UIButton = .init()
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return button
    }()

    init(image: UIImage) {
        super.init(frame: UIScreen.main.bounds)
        setupView(image: image)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupView(image: UIImage) {
        self.addSubviews(backgroundView, imageView, closeButton)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageView.image = image
        imageView.snp.makeConstraints {
            $0.top.bottom.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        closeButton.snp.makeConstraints {
            $0.top.self.equalTo(self.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().inset(20)
        }
    }

    @objc private func dismissView() {
        self.removeFromSuperview()
    }
}
