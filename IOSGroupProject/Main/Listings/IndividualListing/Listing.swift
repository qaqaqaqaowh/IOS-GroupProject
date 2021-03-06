//
//  Listing.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MapKit

class Listing {
    
    
    var listingId: String = ""
    var videoURL: String = ""
    var imageURLS: [String] = []
    var images: [UIImage] = []
    var price: String = ""
    var squareFt: String = ""
    var bedrooms: String = ""
    var owner: String = ""
    var status : Status = .other
    var location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var score: Int = 0

    
    init (){
    }
    
    init(listingId: String, videoURL: String, imageURLS: [String], price: String, location: CLLocationCoordinate2D, squareFt: String, bedrooms: String, owner: String){
        self.listingId = listingId
        self.videoURL = videoURL
        self.imageURLS = imageURLS
        self.price = price
        self.location = location
        self.squareFt = squareFt
        self.bedrooms = bedrooms
        self.owner = owner
    }
    
    
    enum Status {
        case new
        case owned
        case saved
        case other
    }
    
    
    func saveToDatabase(){
        let ref = Database.database().reference()
        let listingRef = ref.child("listings").child(self.listingId)
        var dict:[String:Any] = ["videoURL" : self.videoURL, "price" : self.price, "squareFt" : self.squareFt, "bedrooms" : self.bedrooms, "owner" : self.owner]
        dict["images"] = self.imageURLS
        dict["location"] = ["latitude": self.location.latitude, "longitude":self.location.longitude]
        guard let loggedInUser = Auth.auth().currentUser?.uid
            else{return}
        listingRef.setValue(dict)
        ref.child("users").child(loggedInUser).child("listings").updateChildValues([self.listingId : true])
    }
}
