//
//  APINetwork.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/20.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
import AVFoundation

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

