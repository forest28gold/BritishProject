//
//  Const.swift
//
//  Created by Benjamin Bourasseau on 19/01/2016.
//  Copyright © 2016 Benjamin. All rights reserved.
//

import Foundation
import UIKit

let BUTTON_MARGIN = 10
let BUTTON_RADIUS = 5

let UNWIND_PREVIEW_CLASSIFIED = "unwindPreviewClassified"

let PASSWORD_BAT = "b==================================="
let SUPPORT_EMAIL = "s==================================="
let CONNECTION_EMAIL = "s==================================="
let CONNECTION_CC_EMAIL = "th==================================="
let QUERY_LIMIT = 1000
let NOTI_LIMIT = 35

struct Const {
    
    // MARK: Database Class names
    
    struct Database {
        static let SampleTable = "BAT"
    }
    
    // MARK: User default Keys
    
    struct UserDefaults {
        static var launchedOnce: String {
            return "\(bundleId).launchedOnce"
        }
    }
    
    // MARK: Height and Width
    
    struct Size {
        static let NavBarHeight: CGFloat = 64.0
    }
    
    // MARK: Custom objects
    
    struct NavButtons {
        static let close = NavButton(image: #imageLiteral(resourceName: "navbarClose"), size: CGSize(width: 21.0, height: 20.0))
    }
    
    struct Url {
        private static let appStoreLink = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews"
        static let appStoreRating = "\(appStoreLink)?id=\(Config.App.appStoreId)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
        static let appStoreDownload = "itms-apps://itunes.apple.com/app/x-gift/id\(Config.App.appStoreId)?mt=8&uo=4"
    }
    
    struct Colors {
        
    }
    
    struct ParseClass {
        static let InstallationClass = "I==================================="
        static let UserClass = "U==================================="
        static let UserStatusClass = "U==================================="
        static let ClassifiedsClass = "C==================================="
        static let DepartmentClass = "D==================================="
        static let EventClass = "E==================================="
        static let EventMessageClass = "E==================================="
        static let MessageClass = "M==================================="
        static let NotificationClass = "N==================================="
        static let PostClass = "P==================================="
        static let PostCommentClass = "P==================================="
        
        static let UserCommentClass = "U==================================="
    }
    
    struct PostType {
        static let post = "post"
        static let poll = "poll"
    }
    
    struct CommentStatus {
        static let declined = "declined"
        static let approved = "approved"
        static let pending = "pending"
    }
    
    struct NotiType {
        static let NewPost = "ne==================================="
        static let NewPoll = "ne==================================="
        static let CommentPostDeclined = "co==================================="
        static let CommentPollDeclined = "co==================================="
        static let NewMessage = "ne==================================="
        static let EventLive = "ev==================================="
        static let EventScheduled = "ev==================================="
        
        static let CommentApproved = "co==================================="
    }
}

struct Fonts {
    enum HelveticaNeue: String {
        case light = "Light"
        
        func size(_ size: CGFloat) -> UIFont {
            return UIFont(name: "HelveticaNeue-\(self.rawValue)", size: size)!
        }
    }
}

// MARK: AppDelegate

let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
