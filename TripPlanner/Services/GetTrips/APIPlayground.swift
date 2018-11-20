//
//  APIPlayground.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/20.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
//import PlaygroundSupport

struct APIPlayground : IGetTrips {
    
    func getTrips(_ completion: @escaping OnDataCallback ) {
        
        let file = "/Shared Playground Data/C2.json"
        //let dir = playgroundSharedDataDirectory
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(file)
            do {
                let data = try Data(contentsOf: path)
                let json = try JSONDecoder().decode(Result.self, from: data)
                completion(json,nil)
            }
            catch let ioErr { /* error handling here */
                print(ioErr)
                completion(nil,ioErr)
            }
        }
        
    }
    
}


