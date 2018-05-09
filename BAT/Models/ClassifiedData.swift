//
//  ClassifiedData.swift
//  BAT
//
//  Created by AppsCreationTech on 1/25/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import Foundation
import Parse

struct ClassifiedData {
    
    var name: String
    var price: String
    var desc: String
    
    init(name: String, price: String, desc: String) {
        self.name = name
        self.price = price
        self.desc = desc
    }
}
