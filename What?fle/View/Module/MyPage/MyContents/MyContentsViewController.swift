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
    var myFavoriteCollections: BehaviorRelay<[HomeDataModel.Collection]> { get }
    func popToMyContents()
    func retriveMyFavoriteCollection()
    func updateFavorite(id: Int, isFavorite: Bool)
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

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        self.listener?.retriveMyFavoriteCollection()
    }

    private func setupUI() {
        view.backgroundColor = .white
        self.view.addSubviews(self.customNavigationBar, self.tabView, self.collectionView)
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
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.tabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func handleTabSelection(_ index: Int) {
        self.collectionView.isHidden = index == 0
    }

    private func setupViewBinding() {
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
        self.listener?.myFavoriteCollections.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let myCollections = listener?.myFavoriteCollections.value,
              let myCollection = myCollections[safe: indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseIdentifier, for: indexPath) as? HomeCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath)
        }
        cell.delegate = self
        cell.drawCell(model: myCollection)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32, height: ImageGridType.twoByTwo.cellHeight)
    }
}

extension MyContentsViewController: HomeCellDelegate {
    func didTapFavoriteButton(id: Int, isFavorite: Bool) {
        listener?.updateFavorite(id: id, isFavorite: isFavorite)
    }
}
