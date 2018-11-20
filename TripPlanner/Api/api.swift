//
//  api.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/05.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation

protocol IGetTrips {
    
    typealias OnDataCallback = (_ result: Result?, _ error: Error?) -> Void

    func getTrips(_ completion: @escaping OnDataCallback )

}

struct Loader {
    
    private static let fromData = [
        "South Africa","Seoul","Sweden", "Swiss", "Sydney", "America", "Portugal", "Angola", "Andora", "Amazon"
    ]
    private static let destData = [
        "South Africa","Seoul","Sweden", "Swiss", "America", "Portugal", "Angola", "Andora", "Amazon"
    ]
    
    static public func load(from: [String] = fromData ) -> AutoCompleteDataSource {
        return AutoCompleteDataSource(data: from)
    }
    
}

