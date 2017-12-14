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
    var ownerUID: String!
    var thumbImage: UIImage?
    
    init(withURLString: String, withName: String, withOwner: String, withThumb: UIImage?) {
        self.videoURL = withURLString
        self.name = withName
        self.ownerUID = withOwner
        self.thumbImage = withThumb
    }
}
