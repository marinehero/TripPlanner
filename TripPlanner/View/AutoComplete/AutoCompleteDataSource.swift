//
//  AutoCompleteDataSource.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/05.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation

public class AutoCompleteDataSource {
    var data: [AutoCompletable]
    var autoCompleteTree: AutoCompleteTree?
    
    public init(data: [AutoCompletable]) {
        self.data = data
    }
    
    public func constructTrie(isCaseSensitive: Bool = false) {
        autoCompleteTree = AutoCompleteTrie(dataSource: data, isCaseSensitive: false)
    }
    
    public func insert(autoCompletable: AutoCompletable) {
        data.append(autoCompletable)
        if let autoCompleteTrie = autoCompleteTree {
            autoCompleteTrie.insert(autoCompletable: autoCompletable)
        }
    }
    
    public func remove(allMatching autoCompleteString: String) {
        data = data.filter { $0.autocompleteString != autoCompleteString }
        if let autoCompleteTrie = autoCompleteTree {
            autoCompleteTrie.remove(allMatching: autoCompleteString)
        }
    }
}
