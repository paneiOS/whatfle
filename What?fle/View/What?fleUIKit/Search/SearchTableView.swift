//
//  SearchTableView.swift
//  What?fle
//
//  Created by 이정환 on 10/3/24.
//

import UIKit

final class SearchTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.setupTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupTableView()
    }

    private func setupTableView() {
        self.showsVerticalScrollIndicator = false
        self.keyboardDismissMode = .onDrag
        self.separatorStyle = .none
    }
}
