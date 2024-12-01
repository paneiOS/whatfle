//
//  MyContentsViewController.swift
//  What?fle
//
//  Created by 이정환 on 12/1/24.
//

import UIKit

import RIBs
import RxCocoa
import RxSwift
import SnapKit

protocol MyContentsPresentableListener: AnyObject {
    var myFavoritePlaces: BehaviorRelay<[HomeDataModel.Collection.Place]> { get }
    var myFavoriteCollections: BehaviorRelay<[HomeDataModel.Collection]> { get }
    func popToMyContents()
    func retriveMyFavorites()
    func updateFavoriteLocation(id: Int, isFavorite: Bool)
    func updateFavoriteCollection(id: Int, isFavorite: Bool)
}

final class MyContentsViewController: UIViewController, MyContentsPresentable, MyContentsViewControllable {

    // MARK: - UIComponent

    private lazy var customNavigationBar: CustomNavigationBar = {
        let view: CustomNavigationBar = .init()
        view.setNavigationTitle("나의 관심 왓플", buttonColor: .black)
        return view
    }()

    private lazy var tabView: SegmentedTabView = {
        let view = SegmentedTabView(titles: ["장소", "컬렉션"])
        view.onTabSelected = { [weak self] index in
            guard let self else { return }
            self.handleTabSelection(index)
        }
        return view
    }()

    private lazy var locationsView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .vertical
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(MyLocationSubCell.self, forCellWithReuseIdentifier: MyLocationSubCell.reuseIdentifier)
        collectionView.isHidden = true
        return collectionView
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
        collectionView.isHidden = true
        return collectionView
    }()

    weak var listener: MyContentsPresentableListener?
    private let disposeBag = DisposeBag()

    deinit {
        print("\(self) is being deinit")
    }

    init(initialIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        self.tabView.initialIndex = initialIndex
        self.locationsView.isHidden = initialIndex == 1
        self.collectionView.isHidden = initialIndex == 0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupViewBinding()
        self.setupActionBinding()
        self.listener?.retriveMyFavorites()
    }

    private func setupUI() {
        view.backgroundColor = .white
        self.view.addSubviews(self.customNavigationBar, self.tabView, self.locationsView, self.collectionView)
        self.customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        self.tabView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        self.locationsView.snp.makeConstraints {
            $0.top.equalTo(self.tabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.tabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func handleTabSelection(_ index: Int) {
        self.locationsView.isHidden = index == 1
        self.collectionView.isHidden = index == 0
    }

    private func setupViewBinding() {
        listener?.myFavoritePlaces
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.locationsView.reloadData()
            })
            .disposed(by: self.disposeBag)

        listener?.myFavoriteCollections
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.collectionView.reloadData()
            })
            .disposed(by: self.disposeBag)
    }

    private func setupActionBinding() {
        self.customNavigationBar.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.popToMyContents()
            })
            .disposed(by: self.disposeBag)
    }
}

extension MyContentsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === self.locationsView {
            self.listener?.myFavoritePlaces.value.count ?? 0
        } else {
            self.listener?.myFavoriteCollections.value.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath)
        if collectionView === self.locationsView {
            guard let places = listener?.myFavoritePlaces.value,
                  let place = places[safe: indexPath.item],
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyLocationSubCell.reuseIdentifier, for: indexPath) as? MyLocationSubCell else {
                return emptyCell
            }
            cell.delegate = self
            cell.drawCell(place: place, isFavorite: true)
            return cell
        } else {
            guard let myCollections = listener?.myFavoriteCollections.value,
                  let myCollection = myCollections[safe: indexPath.item],
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseIdentifier, for: indexPath) as? HomeCell else {
                return emptyCell
            }
            cell.delegate = self
            cell.drawCell(model: myCollection)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === self.locationsView {
            return .init(width: collectionView.bounds.width - 32, height: 88)
        } else {
            return CGSize(width: collectionView.bounds.width - 32, height: ImageGridType.twoByTwo.cellHeight)
        }
    }
}

extension MyContentsViewController: HomeCellDelegate {
    func didTapFavoriteCollection(id: Int, isFavorite: Bool) {
        self.listener?.updateFavoriteCollection(id: id, isFavorite: isFavorite)
    }
}

extension MyContentsViewController: MyLocationSubCellDelegate {
    func didTapFavoriteLocation(id: Int, isFavorite: Bool) {
        self.listener?.updateFavoriteLocation(id: id, isFavorite: isFavorite)
    }
}
