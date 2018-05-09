//
//  Error.swift
//  Project
//
//  Created by Benjamin Bourasseau on 13/09/2016.
//  Copyright © 2016 Guaraná Technologies Inc. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics

public extension NSError {
    
    /** Record a non fatal issue on crashlytics */
    public func recordOnCrashlytics(additionalInfo: [String: Any]?, userIdentifier: String?) {
        if let userIdentifier = userIdentifier {
            Crashlytics.sharedInstance().setUserIdentifier(userIdentifier)
        }
        if let additionalInfo = additionalInfo {
            Crashlytics.sharedInstance().recordError(self, withAdditionalUserInfo: additionalInfo)
        } else {
            Crashlytics.sharedInstance().recordError(self)
        }
    }
}
