//
//  MyPageViewController.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import UIKit

import RIBs
import RxSwift
import SnapKit

protocol MyPagePresentableListener: AnyObject {}

final class MyPageViewController: UIViewController, MyPagePresentable, MyPageViewControllable {

    weak var listener: MyPagePresentableListener?
    
    private lazy var headerView: UIView = {
        let view: UIView = .init()
        let label: UILabel = .init()
        label.attributedText = .makeAttributedString(
            text: "마이페이지",
            font: .title20XBD,
            textColor: .GrayScale.g900,
            lineHeight: 28
        )
        view.addSubviews(label, settionButton)
        label.snp.makeConstraints {
            $0.top.equalToSuperview().inset(17)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(9)
        }
        self.settionButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(19)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(11)
            $0.size.equalTo(24)
        }
        return view
    }()

    private let settionButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(.Icon.settingButton, for: .normal)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(SearchButtonCell.self, forCellWithReuseIdentifier: SearchButtonCell.reuseIdentifier)
        collectionView.register(TopCell.self, forCellWithReuseIdentifier: TopCell.reuseIdentifier)
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }

    private func setupUI() {
        self.view.addSubview(self.headerView)
        self.headerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UIApplication.shared.statusBarHeight)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
    }
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath)
    }
}
