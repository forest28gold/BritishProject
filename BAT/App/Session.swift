//
//  Session.swift
//
//  Created by Benjamin Bourasseau on 19/01/2016.
//  Copyright © 2016 Benjamin. All rights reserved.
//

import Foundation
import UIKit

class Session: NSObject {
    
    /*!
    *  The url of the app in the app store
    */
    var appStoreUrl: String?
    
    /*!
    *  If splash has been loaded once
    */
    private var splash: Bool = false
    
    /*!
    *  Minimal version required for running the app
    */
    private var minimalVersion: NSString = "1.0"
    
    /*!
    *  Last version available on the app store
    */
    private var lastVersion: NSString = "1.0"
    
    // MARK: Functions
    
    /*!
    *  Singleton
    */
    static let get = Session()
    
    override init() {
        self.appStoreUrl = localized("generic_appstore")
        super.init()
    }
    
    // MARK: First launch
    
    /*!
    *  Check if it's the first launch of the app
    */
    func isFirstAppLaunch() -> Bool {
        let launchedOnce = UserDefaults.standard.bool(forKey: Const.UserDefaults.launchedOnce)
        if launchedOnce {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: Const.UserDefaults.launchedOnce)
            UserDefaults.standard.synchronize()
            return true
        }
    }
    
    // MARK: Splash
    /*!
    *  Check if splash has been already launched or not
    */
    func splashLoadedOnce() -> Bool {
        return self.splash
    }
    
    /*!
    *  Set the splash as loaded
    */
    func setSplashLoaded() {
        self.splash = true
    }
}
