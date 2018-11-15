//
//  api.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/05.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
//import PlaygroundSupport

var Current = Services()

struct Services {
    
    var api: IGetTrips = APIBundle()
    
}

protocol IGetTrips {
    
    typealias OnDataCallback = (_ result: Result?, _ error: Error?) -> Void

    func getTrips(_ completion: @escaping OnDataCallback )

}

struct Loader {
    
    public static var fromData = [
        "South Africa","Seoul","Sweden", "Swiss", "Sydney", "America", "Portugal", "Angola", "Andora", "Amazon"
    ]
    public static var destData = [
        "South Africa","Seoul","Sweden", "Swiss", "America", "Portugal", "Angola", "Andora", "Amazon"
    ]
    
    static public func load(from: [String] = fromData ) -> AutoCompleteDataSource {
        return AutoCompleteDataSource(data: fromData)
    }
    
}

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

struct APINetwork : IGetTrips {
    
    let endPoint = "https://raw.githubusercontent.com/TuiMobilityHub/ios-code-challenge/master/"
    let sampleFile = "connections.json"
    
    func getTrips(_ completion: @escaping OnDataCallback ) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard let URL = URL(string: "\(endPoint)\(sampleFile)") else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                
                guard let data = data else {
                    completion(nil,nil)
                    print("no data")
                    return
                }
                
                do {
                    let r = try JSONDecoder().decode(Result.self, from: data)
                    completion(r,nil)
                }
                catch let jsonErr {
                    print(jsonErr)
                    completion(nil,jsonErr)
                }
                
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription)
                completion(nil,error)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}

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

