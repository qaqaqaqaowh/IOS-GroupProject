//
//  Setting.swift
//  IOSGroupProject
//
//  Created by NEXTAcademy on 12/15/17.
//  Copyright © 2017 asd. All rights reserved.
//

import Foundation

class Setting {
    var criteria: String!
    var value: Any?
    
    init(withCriteria: String, withValue: Any?) {
        self.criteria = withCriteria
        self.value = withValue
    }
}
