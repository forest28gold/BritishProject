//
//  Notification.swift
//  BAT
//
//  Created by Benjamin Bourasseau on 28/06/2016.
//  Copyright © 2016 Guaraná Technologies Inc. All rights reserved.
//

import Foundation

enum GRNNotif: String {
    
    case sample = "SampleNotifName"
    
    var name: String {
        return "\(Config.App.identifier).\(self.rawValue)"
    }
    
    /** Post Notification */
    func postNotif(_ object: NSObject?) {
        NotificationCenter.default.post(Notification(name: Notification.Name(self.name), object: object, userInfo: nil))
    }
    
    /** Create an observer */
    func addObserver(observer: AnyObject, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name(self.name), object: nil)
    }
    
    func removeObserver(observer: AnyObject) {
        NotificationCenter.default.removeObserver(observer, name: Notification.Name(self.name), object: nil)
    }
    
    /** Observe on the main queue with a completion block */
    func observe(observer: AnyObject, block:@escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: Notification.Name(self.name), object: nil, queue: nil, using: block)
    }
    
    /** Observe on a specified queue with a completion block */
    func observe(observer: AnyObject, onQueue: OperationQueue, block:@escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: Notification.Name(self.name), object: nil, queue: onQueue, using: block)
    }
}
