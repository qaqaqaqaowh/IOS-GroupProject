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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
