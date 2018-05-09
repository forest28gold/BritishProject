//
//  Config.swift
//  BAT
//
//  Created by Benjamin Bourasseau on 19/01/2016.
//  Copyright © 2016 Benjamin. All rights reserved.
//

import Foundation
import Parse

struct Config {
    
    static var isProd = false
    
    struct Parse {
        private static let appId = "b==================================="
        private static let masterKey = "b==================================="
        private static let url = "https://b==================================="
        private static let devAppId = "b==================================="
        private static let devMasterKey = "b==================================="
        private static let devUrl = "https://b==================================="
        
        /** Return Credentials according to isProd value */
        static var credentials: (appId: String, masterKey: String, url: String) {
            if isProd {
                return (appId:Parse.appId, masterKey: Parse.masterKey, url: Parse.url)
            } else {
                return (appId:Parse.devAppId, masterKey: Parse.devMasterKey, url: Parse.devUrl)
            }
        }
    }
    
    static let LOCALE_EN = "en"
    static let LOCALE_ES = "es"
    
    struct App {
     
        /** Identifier on iTunes connect. Used for Rate the App URL */
        static let appStoreId = ""
        
        static let identifier = bundleId
    }
    
        
    static var currentLocale = "en"
    static var deviceId = ""
    static var verifyEmail = ""
    static var isEditProfile = false
    
    static var tabBarCtrl: TabBarViewController? = nil
    static var commentCtrl: PostDetailsViewController? = nil
    static var eventCtrl: EventDetailsViewController? = nil
    static var isMedia = false
    static var isComment = false
    static var strTerms = ""
    static var isEditClassified = false
    static var strDescription = ""
    
    static var isLiveComment = false
    static var fromNotification = false
    static var hasNotification = false
    
    static var departmentArray = [PFObject]()
    static var postArray = [PostData]()
    static var classifiedArray = [PFObject]()
    static var notificationArray = [PFObject]()
    static var directoryArray = [PFUser]()

    static var currentUser: PFUser!
    static var postData: PostData!
    static var classifiedData: PFObject!
    static var classifiedPreviewData: ClassifiedData!
    static var photoArray = [PhotoData]()
    static var messageData: PFObject!
    static var eventData: EventData!
    static var pastEventData: PFObject!
    static var messageArray = [PFObject]()
    static var directoryData: PFUser!
    
    static public func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z.'_%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    static public func onCheckUserStringNull(object: PFUser, key: String) -> String {
        let value = object[key] as? String
        if value == nil {
            return ""
        } else {
            return value!
        }
    }
    
    static public func onCheckUserFileNull(object: PFUser, key: String) -> String {
        let value = object[key] as? PFFile
        if value == nil {
            return ""
        } else {
            return (value?.url)!
        }
    }
    
    static public func onCheckUserArrayNull(object: PFUser, key: String) -> [String] {
        let value = object[key] as? NSArray
        if value == nil {
            return [String]()
        } else {
            return value as! [String]
        }
    }
    
    static public func onCheckStringNull(object: PFObject, key: String) -> String {
        let value = object[key] as? String
        if value == nil {
            return ""
        } else {
            return value!
        }
    }
    
    static public func onCheckNumberNull(object: PFObject, key: String) -> Int {
        let value = object[key] as? NSNumber
        if value == nil {
            return 0
        } else {
            return (value?.intValue)!
        }
    }
    
    static public func onCheckArrayNull(object: PFObject, key: String) -> [String] {
        let value = object[key] as? NSArray
        if value == nil {
            return [String]()
        } else {
            return value as! [String]
        }
    }
    
    static public func onCheckFileNull(object: PFObject, key: String) -> String {
        let value = object[key] as? PFFile
        if value == nil {
            return ""
        } else {
            return (value?.url)!
        }
    }
    
    static public func onCheckDefaultStringNull(key: String) -> String {
        let defaults = UserDefaults.standard
        let value = defaults.string(forKey: key)
        if value == nil {
            return ""
        } else {
            return value!
        }
    }
    
    static public func randomString(length: Int) -> String {
        let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    static public func randomNumber(length: Int) -> String {
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}
