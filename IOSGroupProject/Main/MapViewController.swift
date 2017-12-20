//
//  MapViewController.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/15/17.
//  Copyright © 2017 asd. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewPassCoordDelegate {
    func passCoord(withLogitude: String, withLatitude: String)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: MapViewPassCoordDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longPressMap))
        longTap.minimumPressDuration = 1
        mapView.addGestureRecognizer(longTap)
        // Do any additional setup after loading the view.
    }
    
    @objc func longPressMap(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            let touchPoint = gesture.location(in: mapView)
            let touchCoord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            delegate?.passCoord(withLogitude: String(touchCoord.longitude), withLatitude: String(touchCoord.latitude))
            navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLocationFromAddress(withAddress: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(withAddress) { (placemarks, error) in
            if placemarks != nil {
                let location = placemarks?.first?.location
                self.delegate?.passCoord(withLogitude: String(describing: location?.coordinate.longitude), withLatitude: String(describing: location?.coordinate.latitude))
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
