//
//  HomeViewController.swift
//  What?fle
//
//  Created by 이정환 on 2/24/24.
//

import UIKit

import RIBs
import RxCocoa
import RxSwift
import SnapKit

protocol HomePresentableListener: AnyObject {
    var homeData: BehaviorRelay<HomeDataModel?> { get }
    var currentPage: Int { get }
    func loadData(more: Bool)
    func updateFavorite(id: Int, isFavorite: Bool)
    func showDetailCollection(id: Int)
    func showLoginRIB()
}

final class HomeViewController: UIViewController, HomePresentable, HomeViewControllable {

    weak var listener: HomePresentableListener?
    private let disposeBag = DisposeBag()

    private let searchBarView: SearchBarView = {
        let view: SearchBarView = .init()
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TopCell.self, forCellWithReuseIdentifier: TopCell.reuseIdentifier)
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
        return collectionView
    }()

    private var isFetchingData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupViewBinding()
        self.setupActionBinding()
        self.listener?.loadData(more: false)
    }

    private func setupUI() {
        self.view.addSubviews(self.searchBarView, self.collectionView)
        self.searchBarView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(UIApplication.shared.statusBarHeight + 8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.searchBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    private func setupViewBinding() {
        listener?.homeData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.collectionView.reloadData()
            })
            .disposed(by: self.disposeBag)
    }

    private func setupActionBinding() {}
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let homeData = listener?.homeData.value else { return 0 }
        switch section {
        case 0:
            return 1
        case 1:
            return homeData.contents.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let homeData = listener?.homeData.value else {
            return UICollectionViewCell()
        }
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopCell.reuseIdentifier, for: indexPath) as? TopCell else {
                return UICollectionViewCell()
            }
            cell.drawCell(model: homeData.topSection)
            cell.delegate = self
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseIdentifier, for: indexPath) as? HomeCell,
                  let content = homeData.contents[safe: indexPath.item] else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.drawCell(model: content)
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: 238)
        case 1:
            guard let homeData = listener?.homeData.value,
                  let height = homeData.contents[safe: indexPath.item]?.type.cellHeight else {
                return .zero
            }
            return CGSize(width: collectionView.bounds.width - 32, height: height)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            guard let homeData = listener?.homeData.value,
                  let id = homeData.contents[safe: indexPath.item]?.collection.id else { return }
            self.listener?.showDetailCollection(id: id)
        default: return
        }
    }
}

extension HomeViewController: TopCellDelegate {
    func showDetailCell(id: Int) {
        self.listener?.showDetailCollection(id: id)
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if let count = listener?.homeData.value?.contents.count,
           count > 0,
           offsetY >= contentHeight - height - 10,
           !isFetchingData {
            self.isFetchingData = true
            listener?.loadData(more: true)
        }

        if offsetY < -100, !isFetchingData {
            self.isFetchingData = true
            listener?.loadData(more: false)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isFetchingData = false
    }
}

extension HomeViewController: HomeCellDelegate {
    func didTapFavoriteButton(id: Int, isFavorite: Bool) {
        listener?.updateFavorite(id: id, isFavorite: isFavorite)
    }
}
