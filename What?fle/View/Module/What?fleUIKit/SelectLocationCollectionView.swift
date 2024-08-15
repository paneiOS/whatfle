//
//  SelectLocationCollectionView.swift
//  What?fle
//
//  Created by 이정환 on 8/8/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectLocationCollectionView: UICollectionView {
    private let disposeBag = DisposeBag()

    var items: BehaviorRelay<[PlaceRegistration]> = BehaviorRelay(value: [])

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.itemSize = .init(width: 64, height: 88)
        layout.sectionInset = UIEdgeInsets(top: 6, left: 8, bottom: 4, right: 8)
        super.init(frame: .zero, collectionViewLayout: layout)
        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        self.register(SelectLocationResultCell.self, forCellWithReuseIdentifier: SelectLocationResultCell.reuseIdentifier)
    }

    private func setupBindings() {
        self.dataSource = nil
        self.delegate = nil

        items.bind(to: self.rx.items(
            cellIdentifier: SelectLocationResultCell.reuseIdentifier,
            cellType: SelectLocationResultCell.self)
        ) { (_, model, cell) in
            cell.drawCell(model: model)
        }.disposed(by: disposeBag)
    }
}
