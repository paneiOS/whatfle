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

final class MyPageViewController: UIViewController, MyPagePresentable, MyPageViewControllable, MyFavoriteCellDelegate {

    private enum Constants {
        static let cellWidth: CGFloat = UIApplication.shared.width - 32
    }

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
        layout.minimumLineSpacing = 24.0
        layout.sectionInset = .init(top: 24, left: 16, bottom: 24, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(ProfileViewCell.self, forCellWithReuseIdentifier: ProfileViewCell.reuseIdentifier)
        collectionView.register(MyFavoriteCell.self, forCellWithReuseIdentifier: MyFavoriteCell.reuseIdentifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }

    private func setupUI() {
        self.view.addSubviews(self.headerView, self.collectionView)
        self.headerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UIApplication.shared.statusBarHeight)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

extension MyPageViewController {
    func tapFavoriteLocation() {
        print("관심장소")
    }
    
    func tapFavoriteCollection() {
        print("관심컬렉션")
    }
    
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0, 1: return 1
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath)
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileViewCell.reuseIdentifier, for: indexPath) as? ProfileViewCell,
                  let userInfo = SessionManager.shared.loadUserInfo() else {
                return emptyCell
            }
            cell.drawCell(model: userInfo)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyFavoriteCell.reuseIdentifier, for: indexPath) as? MyFavoriteCell else {
                return emptyCell
            }
            cell.delegate = self
            return cell
        default:
            return emptyCell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return .init(width: Constants.cellWidth, height: 80)
        case 1:
            return .init(width: Constants.cellWidth, height: 103)
        default:
            return .zero
        }
    }
}
