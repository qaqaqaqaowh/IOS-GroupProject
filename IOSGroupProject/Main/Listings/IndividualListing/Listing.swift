//
//  Listing.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import Foundation
import UIKit

class Listing {
    var videoURL: String!
    var name: String!
    var thumbImage: UIImage?
    var price : String?
    var location : String?
    var squareFeet : String?
    var numberOfBedrooms : String?
    
    init(withURLString: String, withName: String, withOwner: String, withThumb: UIImage?) {
        self.videoURL = withURLString
        self.name = withName
        self.thumbImage = withThumb
    }
}
