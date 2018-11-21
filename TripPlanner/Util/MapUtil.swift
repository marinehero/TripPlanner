//
//  MapUtil.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/21.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
//import UIKit
import MapKit

struct MapUtil {
    
    static func makeMap(_ placeholder: String, xPos: CGFloat, yPos: CGFloat, width: CGFloat, height: CGFloat) -> MKMapView {
        let acpFrame = CGRect(x: xPos, y: yPos, width: width, height: height)
        let field = MKMapView(frame: acpFrame)
        field.isZoomEnabled = true
        field.isScrollEnabled = true
        field.isRotateEnabled = true
        field.showsBuildings = true
        field.showsCompass = true
        field.showsScale = true
        field.showsTraffic = false
        field.showsPointsOfInterest = false
        field.showsUserLocation = false
        field.isUserInteractionEnabled = true
        field.isMultipleTouchEnabled = true
        let worldRegion = MKCoordinateRegion(MKMapRect.world)
        field.region = worldRegion
        return field
    }
    
    // This method calculates maprect from coordinates
    static func makeRect(coordinates:[CLLocationCoordinate2D]) -> MKMapRect {
        var rect = MKMapRect()
        var coordinates = coordinates
        if !coordinates.isEmpty {
            let first = coordinates.removeFirst()
            var top = first.latitude
            var bottom = first.latitude
            var left = first.longitude
            var right = first.longitude
            coordinates.forEach { coordinate in
                top = max(top, coordinate.latitude)
                bottom = min(bottom, coordinate.latitude)
                left = min(left, coordinate.longitude)
                right = max(right, coordinate.longitude)
            }
            let topLeft = MKMapPoint(CLLocationCoordinate2D(latitude:top, longitude:left))
            let bottomRight = MKMapPoint(CLLocationCoordinate2D(latitude:bottom, longitude:right))
            rect = MKMapRect(x:topLeft.x, y:topLeft.y,
                             width:bottomRight.x - topLeft.x, height:bottomRight.y - topLeft.y)
        }
        return rect
    }
    
    /// This method draws geodesic polyline
    
    static func drawGeodesic(_ mapView: MKMapView?, schedule: Schedule) {
        
        let existingRoutes = mapView?.overlays
        mapView?.removeOverlays(existingRoutes ?? [])
        
        if let flights = schedule.flights {
            var coordinatesArray = [CLLocationCoordinate2D]()
            for flight in flights {
                guard let sourceLocation = flight.departure?.airportCoordinates() else { break }
                guard let destinationLocation = flight.arrival?.airportCoordinates() else { break }
                var coordinates = [sourceLocation.coordinate,destinationLocation.coordinate]
                let geodesicPolyline = MKGeodesicPolyline(coordinates: &coordinates, count: 2)
                mapView?.addOverlay(geodesicPolyline)
                coordinatesArray.append(sourceLocation.coordinate)
                coordinatesArray.append(destinationLocation.coordinate)
            }
            //mapView?.setVisibleMapRect(self.makeRect(coordinates: coordinatesArray), edgePadding: UIEdgeInsets.init(top: 75.0, left: 75.0, bottom: 75.0, right: 75.0), animated: true)
            let worldRegion = MKCoordinateRegion(MKMapRect.world)
            mapView?.region = worldRegion
        }
        
    }
    
}


