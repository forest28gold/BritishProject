//
//  AppDelegate.swift
//  BAT
//
//  Created by AppsCreationTech on 1/19/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse
import Fabric
import Crashlytics
import GRNForceUpdate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        
        let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        Config.isProd = true
        
        let parseConfiguration = ParseClientConfiguration(block: { (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = Config.Parse.credentials.appId
            ParseMutableClientConfiguration.clientKey = Config.Parse.credentials.masterKey
            ParseMutableClientConfiguration.server = Config.Parse.credentials.url
        })
        Parse.initialize(with: parseConfiguration)
        
        Fabric.with([Crashlytics.self])
        
        DBManager.setUp()
        DBManager.createReadEventTable()
        
//        // Extract the notification data
//        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
//        }

        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            Config.fromNotification = true
        } else {
            Config.fromNotification = false
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let root = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
        let splash = storyboard.instantiateViewController(withIdentifier: "SplashViewController")
        root.setViewControllers([splash], animated: true)
        self.window?.rootViewController = root
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //self.forceUpdateIfNeeded()
        
        if Config.hasNotification && Config.tabBarCtrl != nil {
            Config.tabBarCtrl?.tabBar.items![2].selectedImage = UIImage(named: "ic_tab_notification_alert_selected")
            Config.tabBarCtrl?.tabBar.items![2].image = UIImage(named: "ic_tab_notification_alert")
            Config.hasNotification = false
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PFUser.logOut()
    }

    // MARK: Application Updates
    
    /** Check if update is necessary */
    func forceUpdateIfNeeded() {
        // You need to fetch these parameters
        
        // Minimum app version needed, should be fetched with a call to the backend. Used for TestFlight or Crashlytics (TF)
        let minVersion: String = "1.0.0"
        // The minimal build number to run the app. used for App Store (AS)
        let buildNumber: String = "1"
        // The environment target
        let environment: String = "TF"
        
        if let window = self.window, let controller = self.window?.rootViewController {
            if (!(controller is GRNDefaultScreenVC) && ForceUpdate.isBuildOutdated(minVersion, buildNumber: buildNumber, environment: environment)) {
                window.rootViewController = ForceUpdate.getViewController("Some url", environment: environment)
                window.makeKeyAndVisible()
            }
        }
    }
    
    // MARK: Push Notification Delegate
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.addUniqueObject("mob_bat", forKey: "channels")
        installation?.saveInBackground(block: { (success, error) in
            if success {
                Config.deviceId = (installation?.installationId)!
                print("DEVICE ID = \(String(describing: installation?.installationId))")
                Queue.main.async {
                    if Config.deviceId != "" && Config.currentUser != nil {
                        let statusObject = Config.currentUser["userStatus"] as! PFObject
                        statusObject["deviceId"] = Config.deviceId
                        statusObject.saveInBackground()
                    }
                }
            } else {
                print("TOKEN ERROR = \(error.debugDescription)")
            }
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
//        PFPush.handle(userInfo)
        print("userInfo = ", userInfo.debugDescription)
        let name = userInfo["name"] as! String
        print("name = ", name)
        
        if name.contains(Const.NotiType.NewPost) || name.contains(Const.NotiType.NewPoll) || name.contains(Const.NotiType.NewMessage) || name.contains(Const.NotiType.EventLive) || name.contains(Const.NotiType.EventScheduled) || name.contains(Const.NotiType.CommentPollDeclined) || name.contains(Const.NotiType.CommentPostDeclined) {
            Config.hasNotification = true
            if Config.tabBarCtrl != nil {
                Config.tabBarCtrl?.tabBar.items![2].selectedImage = UIImage(named: "ic_tab_notification_alert_selected")
                Config.tabBarCtrl?.tabBar.items![2].image = UIImage(named: "ic_tab_notification_alert")
            }
        }
        
        if application.applicationState == .inactive {
            
        } else if application.applicationState == .active {
            if name.contains(Const.NotiType.CommentApproved) && Config.isLiveComment {
                Config.commentCtrl?.refreshCommentData()
            }
        } else if application.applicationState == .background {
            
        }
    }
}

