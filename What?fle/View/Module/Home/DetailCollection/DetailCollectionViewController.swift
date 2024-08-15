//
//  DetailCollectionViewController.swift
//  What?fle
//
//  Created by 이정환 on 8/1/24.
//

import Kingfisher
import RIBs
import RxSwift
import RxCocoa
import UIKit

protocol DetailCollectionPresentableListener: AnyObject {
    var detailCollectionModel: PublishSubject<DetailCollectionModel> { get }
    func retriveDetailCollection()
    func popToDetailCollection()
}

final class DetailCollectionViewController: UIViewController, DetailCollectionPresentable, DetailCollectionViewControllable {

    // MARK: - UIComponent

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CoverImageCell.self, forCellWithReuseIdentifier: CoverImageCell.reuseIdentifier)
        collectionView.register(DescriptionCell.self, forCellWithReuseIdentifier: DescriptionCell.reuseIdentifier)
        collectionView.register(SelectionLocationHorizontalCell.self, forCellWithReuseIdentifier: SelectionLocationHorizontalCell.reuseIdentifier)
        collectionView.register(SelectionLocationVerticalCell.self, forCellWithReuseIdentifier: SelectionLocationVerticalCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        collectionView.bounces = false
        collectionView.contentInset = .zero
        collectionView.scrollIndicatorInsets = .zero
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()

    private lazy var customNavigationBar: CustomNavigationBar = {
        let view: CustomNavigationBar = .init()
        view.setNavigationTitle(buttonColor: .white)
        return view
    }()

    private let shadowView: GradientView = {
        let view: GradientView = .init(colors: [.black.withAlphaComponent(0.4), .black.withAlphaComponent(0)])
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Property

    weak var listener: DetailCollectionPresentableListener?
    private let disposeBag = DisposeBag()
    private var model: DetailCollectionModel?
    private lazy var cellHeights: [CGFloat] = [
        UIApplication.shared.width, 96, 172, CGFloat(self.model?.places.count ?? 0) * 512.0, 200
    ] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    deinit {
        print("\(self) is being deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewBinding()
        setupActionBinding()
        listener?.retriveDetailCollection()
    }

    private func setupUI() {
        view.backgroundColor = .white

        [self.collectionView, self.shadowView, self.customNavigationBar].forEach {
            self.view.addSubview($0)
        }
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        self.shadowView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }
    }

    private func setupViewBinding() {
        listener?.detailCollectionModel
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                guard let self else { return }
                self.model = model
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func setupActionBinding() {
        self.customNavigationBar.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.listener?.popToDetailCollection()
            })
            .disposed(by: disposeBag)
    }
}

extension DetailCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard model != nil else { return 0 }
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard model != nil else { return 0 }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model else { return UICollectionViewCell() }
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CoverImageCell.reuseIdentifier, for: indexPath) as? CoverImageCell,
                  let urlStr = model.imageURLs.first else {
                return UICollectionViewCell()
            }
            cell.drawCell(urlStr: urlStr)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DescriptionCell.reuseIdentifier, for: indexPath) as? DescriptionCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.drawCell(model: model)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectionLocationHorizontalCell.reuseIdentifier, for: indexPath) as? SelectionLocationHorizontalCell else {
                return UICollectionViewCell()
            }
            cell.drawCell(places: model.places)
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectionLocationVerticalCell.reuseIdentifier, for: indexPath) as? SelectionLocationVerticalCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.drawCell(places: model.places)
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: self.cellHeights[safe: indexPath.section] ?? 0.0)
    }
}

extension DetailCollectionViewController: SelectionLocationVerticalCellDelegate {
    func cell(_ cell: SelectionLocationVerticalCell, didUpdateHeight height: CGFloat) {
        if self.cellHeights[safe: 3] != height {
            self.cellHeights[3] =  height
        }
    }
}

extension DetailCollectionViewController: DescriptionCellDelegate {
    func cell(_ cell: DescriptionCell, didUpdateHeight height: CGFloat) {
        if self.cellHeights[safe: 1] != height {
            self.cellHeights[1] =  height
        }
    }
}
