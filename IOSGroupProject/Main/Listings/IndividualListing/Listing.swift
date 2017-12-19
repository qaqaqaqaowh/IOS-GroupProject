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

class Listing {
    
    
    var listingId: String = ""
    var videoURL: String = ""
    var imageURLS: [String] = []
    var images: [UIImage] = []
    var price: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var squareFt: String = ""
    var bedrooms: String = ""
    var owner: String = ""
    var status : Status = .other
    
    init (){
    }
    
    init(listingId: String, videoURL: String, imageURLS: [String], price: String, latitude: String, longitude: String, squareFt: String, bedrooms: String, owner: String){
        self.listingId = listingId
        self.videoURL = videoURL
        self.imageURLS = imageURLS
        self.price = price
        self.latitude = latitude
        self.longitude = longitude
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
        listingRef.updateChildValues(["videoURL" : self.videoURL, "price" : self.price, "squareFt" : self.squareFt, "bedrooms" : self.bedrooms, "owner" : self.owner])
        for i in 0..<self.imageURLS.count {
            listingRef.child("images").updateChildValues(["\(i)" : self.imageURLS[i]])
        }
        listingRef.child("location").updateChildValues(["latitude" : self.latitude, "longitude" : self.longitude])
        guard let loggedInUser = Auth.auth().currentUser?.uid
            else{return}
        ref.child("users").child(loggedInUser).child("listings").updateChildValues([self.listingId : true])
    }
}
