//
//  Services.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/20.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation

var Current = Services()

struct Services {
    
    var api: IGetTrips = APIBundle()
    var svc: ILoader = Loader()
    
}
