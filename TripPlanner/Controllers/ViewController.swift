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
        Current.api = APINetwork() // APIBundle([Bundle(for: ViewController.self)]) // APINetwork()
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
            let (total,schedule,fromData,destData) =
                Strategy.calculateCheapestFlight(from: (self.fromAirport?.text)!, dest: (self.destAirport?.text)!, data: data)
            self.refreshDataSources(fromData: fromData, destData: destData)
            self.lbl?.text = "\(total)"
            MapUtil.drawGeodesic(self.mapView, schedule: schedule)
        }
        
    }

}

//MARK: data related

extension ViewController {
    
    private func refreshDataSources(fromData: AutoCompleteDataSource, destData: AutoCompleteDataSource) {
        let departures = fromData
        let arrivals = destData
        fromAirport?.load(dataSource: departures)
        destAirport?.load(dataSource: arrivals)
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
        
        btn?.layer.cornerRadius = CGFloat.Theme.defaultProfile.cornerRadius
        btn?.layer.borderWidth = CGFloat.Theme.defaultProfile.borderWidth
        btn?.layer.borderColor = UIColor.Theme.defaultProfile.buttonBorder.cgColor
        btn?.backgroundColor = UIColor.Theme.defaultProfile.buttonBackground
        btn?.setTitleColor(UIColor.Theme.defaultProfile.buttonText, for: UIControl.State.normal)
        btn?.setTitle("Calc", for: .normal)
        btn?.addTarget(self, action: #selector(actionBtnDidPress(_ :)), for: .touchUpInside)
        
        lbl?.text = "0.0"
        
        let ym = rrc.minY+rrc.height+20
        mapView = MapUtil.makeMap("Map", xPos: 0, yPos:ym, width: view.bounds.width, height: view.bounds.height-ym)
        mapView?.delegate = self

        view.addSubview(fromAirport!)
        view.addSubview(destAirport!)
        view.addSubview(btn!)
        view.addSubview(lbl!)
        view.addSubview(mapView!)

        let sourceData = Current.svc.load(nil)
        
        refreshDataSources(fromData: sourceData, destData: sourceData )
        
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
            return annotationView
        }
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
