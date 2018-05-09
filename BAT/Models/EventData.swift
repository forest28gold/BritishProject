//
//  EventData.swift
//  BAT
//
//  Created by AppsCreationTech on 1/25/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import Foundation
import Parse

struct EventData {
    
    var objectId: String
    var eventObject: PFObject
    var title: String
    var date: Date
    var question: String
    var streamingUrl: String
    var is_read: Bool
    
    init(objectId: String, eventObject: PFObject, title: String, date: Date, question: String, streamingUrl: String, is_read: Bool) {
        
        self.objectId = objectId
        self.eventObject = eventObject
        self.title = title
        self.date = date
        self.question = question
        self.streamingUrl = streamingUrl
        self.is_read = is_read
    }
}
