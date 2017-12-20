//
//  CurrentUser.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/19/17.
//  Copyright © 2017 asd. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import MapKit

class CurrentUser {
    
    
    static var uid : String = Auth.auth().currentUser!.uid
    static var location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    static var squareFt: String = ""
    static var price: String = ""
    static var bedrooms: String = ""
    
    
    static func saveToDatabase(){
        let ref = Database.database().reference()
        let settingsRef = ref.child("users").child(CurrentUser.uid).child("settings")
        settingsRef.updateChildValues(["price" : CurrentUser.price, "squareFt" : CurrentUser.squareFt, "bedrooms" : CurrentUser.bedrooms])
        settingsRef.child("location").updateChildValues(["latitude" : CurrentUser.location.latitude, "longitude" : CurrentUser.location.longitude])
    }
    
    
    static func getSettings(completion: @escaping () -> Void) {
        let ref = Database.database().reference()
        let settingsRef = ref.child("users").child(CurrentUser.uid).child("settings")
        settingsRef.observeSingleEvent(of: .value, with: { (data) in
            guard let validData = data.value as? [String:Any],
                let location = validData["location"] as? [String:Any],
                let bedrooms = validData["bedrooms"] as? String,
                let squareFt = validData["squareFt"] as? String,
                let price = validData["price"] as? String,
                let longitude = location["longitude"] as? Double,
                let latitude = location["latitude"] as? Double
            else{return}
            CurrentUser.location.longitude = longitude
            CurrentUser.location.latitude = latitude
            CurrentUser.bedrooms = bedrooms
            CurrentUser.squareFt = squareFt
            CurrentUser.price = price
            completion()
        })
    }
}
