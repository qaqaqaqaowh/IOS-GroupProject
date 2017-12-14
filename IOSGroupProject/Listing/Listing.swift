//
//  Listing.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/12/17.
//  Copyright © 2017 asd. All rights reserved.
//

import Foundation

class Listing {
    var videoURL: String!
    var viewCount: Int!
    var ownerUID: String!
    
    init(withURLString: String, withViewCount: Int, withOwner: String) {
        self.videoURL = withURLString
        self.viewCount = withViewCount
        self.ownerUID = withOwner
    }
}
