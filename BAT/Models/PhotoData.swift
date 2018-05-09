//
//  PhotoData.swift
//  BAT
//
//  Created by AppsCreationTech on 1/25/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import Foundation

struct PhotoData {
    
    var isEdit: Bool
    var isRemove: Bool
    var photoUrl: String
    var photo: UIImage
    
    init(isEdit: Bool, isRemove: Bool, photoUrl: String, photo: UIImage) {
        
        self.isEdit = isEdit
        self.isRemove = isRemove
        self.photoUrl = photoUrl
        self.photo = photo
    }
}
