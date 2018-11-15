//
//  AutoCompleteACViewController.swift
//  TripPlanner
//
//  Created by James Pereira on 2018/11/03.
//  Copyright © 2018 Code Challenge. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ViewController: UIViewController {
    
    var fromAirport: AutoCompleteTextField?
    var destAirport: AutoCompleteTextField?
    var btn: UIButton?
    var lbl: UILabel?
    var mapView: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Theme.defaultProfile.mainBackground
    }
    
    override func viewWillLayoutSubviews() {
        layoutViewPage()
    }
 
    @objc func actionBtnDidPress(_ sender: UIButton) {
        view.endEditing(true)
        Current.api = APIBundle([Bundle(for: ViewController.self)]) // APINetwork()
        Strategy.getTrips(using: Current.api, onDataAvailable)
    }

}

//MARK: Solution: Using BellmanFord algorithm calculate the shortest path weighted cost

extension ViewController {
    
    public func onDataAvailable(_ result: Result?, _ errorThrown: Error? ) {
        
        if let error = errorThrown {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "ⓘ", message: "Data failed : \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil)) //  ✔
                self.present(alert, animated: true)
            }
            return
        }
        
        guard let data = result else {
            print("error: no data")
            return
        }
        
        DispatchQueue.main.async {
            let (total,schedule) = Strategy.calculateCheapestFlight(from: (self.fromAirport?.text)!, dest: (self.destAirport?.text)!, data: data)
            self.fromAirport?.load(dataSource: Loader.load(from: Loader.fromData))
            self.destAirport?.load(dataSource: Loader.load(from: Loader.destData))
            self.lbl?.text = "\(total)"
            self.drawGeodesic(schedule)
        }
        
    }

}

//MARK: Layout methods

extension ViewController {
    
    private func layoutViewPage() {
        
        let controls: [UIView?] = [fromAirport,destAirport,btn,lbl]
        
        controls.forEach({
            if let ctl = $0 {
                ctl.removeFromSuperview()
            }
        })
        
        let height: CGFloat = 40.0
        let width = (self.view.bounds.width - (2 * Layout.pad.rawValue))/2
        
        fromAirport = makeAutoCompleteField("From", xPos: 0, yPos:80, width: width, height: height)
        destAirport = makeAutoCompleteField("Destination", xPos: width+10, yPos:80, width: width, height: height)

        fromAirport?.text = "Los Angeles"
        destAirport?.text = "Cape Town"
        
        let brc = CGRect(x:10,      y:0+((fromAirport?.maxResultListHeight)!*2), width:80,  height:40)
        let rrc = CGRect(x:width+10,y:0+((fromAirport?.maxResultListHeight)!*2), width:100, height:40)

        btn = UIButton(frame: brc)
        lbl = UILabel(frame: rrc)
        
        btn?.layer.cornerRadius = 5
        btn?.layer.borderWidth = 1
        btn?.layer.borderColor = UIColor.Theme.defaultProfile.buttonBorder.cgColor
        btn?.backgroundColor = UIColor.Theme.defaultProfile.buttonBackground
        btn?.setTitleColor(UIColor.Theme.defaultProfile.buttonText, for: UIControl.State.normal)
        btn?.setTitle("Calc", for: .normal)
        btn?.addTarget(self, action: #selector(actionBtnDidPress(_ :)), for: .touchUpInside)
        
        lbl?.text = "0.0"
        
        let ym = rrc.minY+rrc.height+20
        mapView = makeMap("Map", xPos: 0, yPos:ym, width: view.bounds.width, height: view.bounds.height-ym)

        view.addSubview(fromAirport!)
        view.addSubview(destAirport!)
        view.addSubview(btn!)
        view.addSubview(lbl!)
        view.addSubview(mapView!)

        fromAirport?.load(dataSource: Loader.load(from: Loader.fromData))
        destAirport?.load(dataSource: Loader.load(from: Loader.destData))

    }

}

//MARK: Use default empty delegate

extension ViewController : AutoCompleteTextFieldDelegate {
}

//MARK: Factory methods

extension ViewController {
    
    func makeAutoCompleteField(_ placeholder: String, xPos: CGFloat, yPos: CGFloat, width: CGFloat, height: CGFloat) -> AutoCompleteTextField {
        let acpFrame = CGRect(x: Layout.pad.rawValue + xPos,
                              y: yPos, //(self.view.frame.maxY / 4),
                              width: width,
                              height: height)
        let field = AutoCompleteTextField(frame: acpFrame)
        field.clearButtonMode = .always
        field.placeholder = placeholder
        field.borderStyle = UITextField.BorderStyle.line
        field.autocompleteDelegate = self
        return field
    }
    
}

extension ViewController {
    
    func makeMap(_ placeholder: String, xPos: CGFloat, yPos: CGFloat, width: CGFloat, height: CGFloat) -> MKMapView {
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
        field.delegate = self
        return field
    }
    
    // This method calculates maprect from coordinates
    func makeRect(coordinates:[CLLocationCoordinate2D]) -> MKMapRect {
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
    
    func drawGeodesic(_ schedule: Schedule) {

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

extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer() }
        
        let overlayRenderer = MKPolylineRenderer(polyline: polyline)
        overlayRenderer.lineWidth = 3.0
        overlayRenderer.alpha = 0.5
        if polyline is MKGeodesicPolyline{
            overlayRenderer.strokeColor = UIColor.blue
        } else {
            overlayRenderer.strokeColor = UIColor.red
        }
        return overlayRenderer
    }

    func mapView(_ mapView: MKMapView, viewFor viewForAnnotation: MKAnnotation) -> MKAnnotationView? {
        let planeIdentifier = "Plane"
        let reuseIdentifier = "Marker"
        if viewForAnnotation.title == planeIdentifier {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: planeIdentifier)
                ?? MKAnnotationView(annotation: viewForAnnotation, reuseIdentifier: planeIdentifier)
            annotationView.image = UIImage(named: "airplane")
            //annotationView.transform.rotated(by: CGFloat(degreesToRadians(degrees: self.planeDirection)))
            return annotationView
        } else {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if #available(iOS 11.0, *) {
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: viewForAnnotation, reuseIdentifier: reuseIdentifier)
                }
                view?.displayPriority = .required
            } else {
                if view == nil {
                    view = MKPinAnnotationView(annotation: viewForAnnotation, reuseIdentifier: reuseIdentifier)
                }
            }
            view?.annotation = viewForAnnotation
            view?.canShowCallout = true
            return view
        }
    }
    
    private func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / Double.pi
    }
    
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }
    
}
