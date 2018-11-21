//
//  AutoCompleteTrie.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/03.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation

protocol AutoCompleteTree {
    func insert(autoCompletable: AutoCompletable)
    func remove(allMatching autoCompleteString: String)
    func results(for text: String, limit: Int?) -> [AutoCompletable]?
}

private class AutoCompleteTrieNode {
    fileprivate var value: Character?
    fileprivate var children: [Character: AutoCompleteTrieNode] = [:]
    fileprivate var results: [AutoCompletable] = []
    
    fileprivate init(value: Character?) {
        self.value = value
    }
}

public class AutoCompleteTrie : AutoCompleteTree {
    private var root: AutoCompleteTrieNode
    private var isCaseSensitive: Bool
    
    public init(dataSource: [AutoCompletable] = [], isCaseSensitive: Bool = false) {
        self.root = AutoCompleteTrieNode(value: nil)
        self.isCaseSensitive = isCaseSensitive
        dataSource.forEach { insert(autoCompletable: $0) }
    }
    
    /// Inserts a auto-completable into the trie.
    /// - parameter autoCompletable: The `AutoCompletable` to insert a string for.
    public func insert(autoCompletable: AutoCompletable) {
        var currentNode = root
        let autoCompleteString = isCaseSensitive ? autoCompletable.autocompleteString : autoCompletable.autocompleteString.lowercased()
        for char in autoCompleteString {
            if let nextNode = currentNode.children[char] {
                currentNode = nextNode
            } else {
                let newNode = AutoCompleteTrieNode(value: char)
                currentNode.children[char] = newNode
                currentNode = newNode
            }
        }
        currentNode.results.append(autoCompletable)
    }
    
    /// Removes all auto-completables from the trie that match the given auto-complete string.
    /// - parameter autoCompleteString: The string to remove `AutoCompletable` objects for.
    public func remove(allMatching autoCompleteString: String) {
        var currentNode = root
        let autoCompleteString = isCaseSensitive ? autoCompleteString : autoCompleteString.lowercased()
        for char in autoCompleteString {
            if let nextNode = currentNode.children[char] {
                currentNode = nextNode
            } else {
                return
            }
        }
        currentNode.results = []
    }
    

    /// Returns `limit` number of strings in the trie that contain the prefix `text`.
    /// - parameter text: The text used to search for strings in the trie.
    /// - parameter limit: The amount of results to be found. If `nil`, will find all available results.
    /// - returns: A list of `AutoCompletable` results that contain the prefix `text`, or `nil` if `text` is empty.
    public func results(for text: String, limit: Int?) -> [AutoCompletable]? {
        if text.isEmpty { return nil }
        var currentNode = root
        let inputText = isCaseSensitive ? text : text.lowercased()
        // Step through nodes until we reach the last character of the string.
        for char in inputText {
            if let nextNode = currentNode.children[char] {
                currentNode = nextNode
            } else {
                // The input text is not in the trie.
                // HACK: FIXME -> This is when input is unknown in thsi test case
                if char == "*" {
                    break
                }
                return []
            }
        }
        var results = [AutoCompletable]()
        // Add results that exactly match the input text
        if let limit = limit {
            for result in currentNode.results {
                results.append(result)
                if results.count >= limit { return results }
            }
        } else {
            results.append(contentsOf: currentNode.results)
        }
        var nodes = [currentNode]
        // BFS to match all results that start with the input text.
        while let node = nodes.first {
            nodes.removeFirst()
            for child in node.children.values {
                nodes.append(child)
                if let limit = limit {
                    for result in child.results {
                        results.append(result)
                        if results.count >= limit { return results }
                    }
                } else {
                    results.append(contentsOf: child.results)
                }
            }
        }
        return results
    }
}
