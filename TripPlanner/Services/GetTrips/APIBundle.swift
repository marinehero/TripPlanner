//
//  APIBundle.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/20.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
import UIKit

struct APIBundle : IGetTrips {
    
    private let bundles: [Bundle]
    
    init(_ bundles: [Bundle] = [] ) {
        self.bundles = bundles
    }
    
    // Available files are C0 C1 and C2
    
    private let sampleFile = "C0"
    
    func getTrips(_ completion: @escaping OnDataCallback ) {
        
        bundles.forEach { (bundle: Bundle) in
            
            if let jsonPath = bundle.path(forResource: sampleFile, ofType: "json") {
                
                let url = URL(fileURLWithPath: jsonPath)
                
                do {
                    let jsonData = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
                    let json = try JSONDecoder().decode(Result.self, from: jsonData)
                    completion(json,nil)
                    return
                    
                } catch {
                    assert(false, "Bundle: \(bundle) reading services json error: \(error)")
                    return
                    //throw Current.errors.serviceJsonParseError
                }
                
            } else {
                assert(false, "Services.json not found in bundle: \(bundle)")
                return
                //throw Current.errors.serviceJsonMissing
            }
            
        }
    }
    
}

