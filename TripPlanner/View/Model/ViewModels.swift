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

/*
 
 Latitude measures how far north or south of the equator a place is located. The equator is situated at 0°, the North Pole at 90° north (or 90°, because a positive latitude implies north), and the South Pole at 90° south (or –90°). Latitude measurements range from 0° to (+/–)90°.
 
 Longitude measures how far east or west of the prime meridian a place is located. The prime meridian runs through Greenwich, England. Longitude measurements range from 0° to (+/–)180°.
 
 */

struct Departure {
    
    var latlong: LatLong
    
    init(_ latlong: LatLong) {
        self.latlong = latlong
    }
    
    func airportCoordinates() -> CLLocation? {
        var lat = latlong.lat
        var long = latlong.long
        if lat < -90 { lat = -90 }
        if lat > 90 { lat = 90 }
        if long < -180 { long = -180 }
        if long > 180 { long = 180 }
        return CLLocation(latitude: lat, longitude: long )
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


