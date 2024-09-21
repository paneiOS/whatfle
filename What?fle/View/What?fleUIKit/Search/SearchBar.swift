//
//  SearchBar.swift
//  What?fle
//
//  Created by 이정환 on 2/27/24.
//

import UIKit

protocol SearchBarDelegate: AnyObject {
    func searchBarSearchButtonClicked(searchText: String)
    func searchBarCancelButtonClicked()
}

class SearchBar: UISearchBar {
    weak var searchBarDelegate: SearchBarDelegate?

    convenience init(placeholder: String) {
        self.init()

        self.placeholder = placeholder
        self.delegate = self
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            searchBarDelegate?.searchBarSearchButtonClicked(searchText: searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarDelegate?.searchBarCancelButtonClicked()
    }
}

extension SearchBar: UISearchBarDelegate {}
