//
//  Models.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/06.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
import MapKit

//////////////////////////////////////////////////////////////////////////////
/// View Models
//////////////////////////////////////////////////////////////////////////////

struct Departure {
    
    var latlong: LatLong
    
    init(_ latlong: LatLong) {
        self.latlong = latlong
    }
    
    func airportCoordinates() -> CLLocation? {
        return CLLocation(latitude: latlong.lat, longitude: latlong.long )
    }
}

struct Flight {
    var arrival: Departure?
    var departure: Departure?
    init(arrival: Departure, departure: Departure) {
        self.arrival = arrival
        self.departure = departure
    }
}

struct Schedule {
    var flights: [Flight]?
    init() {
        flights = []
    }
}


