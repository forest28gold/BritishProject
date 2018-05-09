//
//  PostData.swift
//  BAT
//
//  Created by AppsCreationTech on 1/19/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import Foundation
import Parse

struct PostData {
    
    var objectId: String
    var postObject: PFObject
    var type: String
    var time: Date
    var nbLikes: Int
    var nbComments: Int
    var nbVote: Int
    var is_like: Bool
    var is_voted: Bool
    
    init(objectId: String, postObject: PFObject, type: String, time: Date,
          nbLikes: Int, nbComments: Int, nbVote: Int, is_like: Bool, is_voted: Bool) {
        
        self.objectId = objectId
        self.postObject = postObject
        self.type = type
        self.time = time
        self.nbLikes = nbLikes
        self.nbComments = nbComments
        self.nbVote = nbVote
        self.is_like = is_like
        self.is_voted = is_voted
    }
}
