//
//  MyPageViewController.swift
//  What?fle
//
//  Created by 이정환 on 10/30/24.
//

import UIKit

import RIBs
import RxSwift
import RxCocoa
import SnapKit

protocol MyPagePresentableListener: AnyObject {
    var myPageDataModel: PublishRelay<MyPageDataModel> { get }
    func loadData()
    func showDetailCollection(id: Int)
}

final class MyPageViewController: UIViewController, MyPagePresentable, MyPageViewControllable, MyFavoriteCellDelegate {

    private enum Constants {
        static let cellWidth: CGFloat = UIApplication.shared.width - 32
    }

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
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .vertical
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 24, left: 16, bottom: 24, right: 16)
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(ProfileViewCell.self, forCellWithReuseIdentifier: ProfileViewCell.reuseIdentifier)
        collectionView.register(MyFavoriteCell.self, forCellWithReuseIdentifier: MyFavoriteCell.reuseIdentifier)
        collectionView.register(MyCollectionsCell.self, forCellWithReuseIdentifier: MyCollectionsCell.reuseIdentifier)
        collectionView.register(MyLocationsCell.self, forCellWithReuseIdentifier: MyLocationsCell.reuseIdentifier)
        return collectionView
    }()

    weak var listener: MyPagePresentableListener?
    private let disposeBag = DisposeBag()
    private var model: MyPageDataModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupViewBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.listener?.loadData()
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

    private func setupViewBinding() {
        listener?.myPageDataModel
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self else { return }
                self.model = model
                self.collectionView.reloadData()
            })
            .disposed(by: self.disposeBag)
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
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
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
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionsCell.reuseIdentifier, for: indexPath) as? MyCollectionsCell,
                  let collections = self.model?.collections else {
                return emptyCell
            }
            cell.delegate = self
            cell.drawCell(model: collections)
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyLocationsCell.reuseIdentifier, for: indexPath) as? MyLocationsCell,
                  let places = self.model?.places else {
                return emptyCell
            }
            cell.drawCell(model: places)
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
        case 2:
            return .init(width: Constants.cellWidth, height: 218)
        case 3:
            return .init(width: Constants.cellWidth, height: 472)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .zero
        } else {
            return .init(top: 24, left: 0, bottom: 0, right: 0)
        }
    }
}

extension MyPageViewController: MyCollectionsCellDelegate {
    func showDetailCollection(id: Int) {
        self.listener?.showDetailCollection(id: id)
    }
}
