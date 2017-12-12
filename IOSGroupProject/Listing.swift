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
    
    init(withURLString: String, withViewCount: Int) {
        self.videoURL = withURLString
        self.viewCount = withViewCount
    }
}
