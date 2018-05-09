//
//  Route.swift
//  BAT
//
//  Created by Benjamin Bourasseau on 20/01/2016.
//  Copyright © 2016 Benjamin. All rights reserved.
//

import Foundation
import UIKit

/* Define your routes here. For Login in Storyboard, add the LoginController identifier. You can then access it using Route.routeLogin.identifier.
   For Segues beetween screens name it like : FirstToSecond, then use : Route.routeFirst.to(.routeSecond)
 */
public enum Route: String {
    
    case routeSplash = "Splash", routeWelcome = "Welcome", routeLogin = "Login", routeTabBar = "TabBar"
    
    /*! Return the view controller identifier */
    public var identifier: String {
        return "\(self.rawValue)Controller"
    }
    
    /*! Return the segue associated to the destination ex: LoginToSignup */
    public func to(_ to: Route) -> String {
        return "\(self.rawValue)To\(to.rawValue)"
    }
    
    /*! Return the unwindSegue associated to the destination ex: unWindSignupToLogin */
    public func unwind(_ to: Route) -> String {
        return "unwind\(self.rawValue)To\(to.rawValue)WithSegue"
    }
}
