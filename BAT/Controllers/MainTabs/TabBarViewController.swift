//
//  TabBarViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse

class TabBarViewController: UITabBarController, UIGestureRecognizerDelegate {
    
    let titles: NSArray = [localized("tab_home"),
                           localized("tab_classifieds"),
                           localized("tab_notifications"),
                           localized("tab_events"),
                           localized("tab_directory")]
    
    let imagesSelected: NSArray = ["ic_tab_home_selected",
                                    "ic_tab_classified_selected",
                                    "ic_tab_notification_selected",
                                    "ic_tab_event_selected",
                                    "ic_tab_directory_selected"]
    
    let imagesNormal: NSArray = ["ic_tab_home",
                                  "ic_tab_classified",
                                  "ic_tab_notification",
                                  "ic_tab_event",
                                  "ic_tab_directory"]
    
    let imagesAlertSelected: NSArray = ["ic_tab_home_selected",
                                   "ic_tab_classified_selected",
                                   "ic_tab_notification_alert_selected",
                                   "ic_tab_event_selected",
                                   "ic_tab_directory_selected"]
    
    let imagesAlertNormal: NSArray = ["ic_tab_home",
                                 "ic_tab_classified",
                                 "ic_tab_notification_alert",
                                 "ic_tab_event",
                                 "ic_tab_directory"]
    
    var controllers: [UIViewController] = []
    
    var navigationControllers: [NSObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loadLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        swipeToPop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation Back Swipe Gesture
    
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return true
        }
        return false
    }

    // MARK: Layout
    
    func loadLayout() {
        
        Config.tabBarCtrl = self
        
        let pre = Locale.preferredLanguages[0]
        if pre.range(of:"es") != nil {
            Config.currentLocale = Config.LOCALE_ES
        } else {
            Config.currentLocale = Config.LOCALE_EN
        }
        
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "TabHomeViewController") as! TabHomeViewController
        let classifiedsVC = self.storyboard?.instantiateViewController(withIdentifier: "TabClassifiedsViewController") as! TabClassifiedsViewController
        let notificationsVC = self.storyboard?.instantiateViewController(withIdentifier: "TabNotificationsViewController") as! TabNotificationsViewController
        let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "TabEventsViewController") as! TabEventsViewController
        let directoryVC = self.storyboard?.instantiateViewController(withIdentifier: "TabDirectoryViewController") as! TabDirectoryViewController
        
        controllers = [homeVC, classifiedsVC, notificationsVC, eventsVC, directoryVC]
        
        let installation = PFInstallation.current()
        if installation?.badge != 0 {
            self.createAlertTabbar()
        } else {
            self.createTabbar()
        }
    }
    
    func createAlertTabbar() {
        
        for indexCount in 0..<self.controllers.count {
            
            let navigationController = UINavigationController(rootViewController:self.controllers[indexCount])
//            navigationController.tabBarItem.title = self.titles[indexCount] as? String
//            navigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 2)], for: .normal)
            navigationController.navigationBar.isHidden = true
            navigationController.tabBarItem.title = nil
            navigationController.tabBarItem.image = UIImage.init(named: self.imagesAlertNormal[indexCount] as! String)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            navigationController.tabBarItem.selectedImage = UIImage.init(named: self.imagesAlertSelected[indexCount] as! String)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            self.navigationControllers.append(navigationController)
        }
        
        self.viewControllers = (self.navigationControllers as! [UIViewController] as NSArray) as? [UIViewController]
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = UIColor.white
        
        if Config.fromNotification {
            self.selectedIndex = 2
        } else {
            self.selectedIndex = 0
        }
    }
    
    func createTabbar() {
        
        for indexCount in 0..<self.controllers.count {
            
            let navigationController = UINavigationController(rootViewController:self.controllers[indexCount])
//            navigationController.tabBarItem.title = self.titles[indexCount] as? String
//            navigationController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 2)], for: .normal)
            navigationController.navigationBar.isHidden = true
            navigationController.tabBarItem.title = nil
            navigationController.tabBarItem.image = UIImage.init(named: self.imagesNormal[indexCount] as! String)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            navigationController.tabBarItem.selectedImage = UIImage.init(named: self.imagesSelected[indexCount] as! String)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            self.navigationControllers.append(navigationController)
        }
        
        self.viewControllers = (self.navigationControllers as! [UIViewController] as NSArray) as? [UIViewController]
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = UIColor.white
        
        if Config.fromNotification {
            self.tabBar.items![2].selectedImage = UIImage(named: "ic_tab_notification_alert_selected")
            self.tabBar.items![2].image = UIImage(named: "ic_tab_notification_alert")
            self.selectedIndex = 2
        } else {
            self.selectedIndex = 0
        }
    }

    // MARK: Action
    
    func onSeeMyProfile() {
        Config.isEditProfile = true
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func onTermsOfUse() {
        Config.strTerms = localized("home_terms_use")
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUseViewController") as! TermsOfUseViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func onPrivacyPolicy() {
        Config.strTerms = localized("home_privacy_policy")
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUseViewController") as! TermsOfUseViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func onLogout() {
        let root = storyboard?.instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
        let home = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController")
        root.setViewControllers([home!], animated: true)
        UIApplication.shared.keyWindow?.rootViewController = root
    }
    
    func onPostDetails() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsViewController") as! PostDetailsViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func onPhotoView() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        self.navigationController?.present(nextViewController, animated: true, completion: nil)
    }
    
    func onVideoView() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
        self.navigationController?.present(nextViewController, animated: true, completion: nil)
    }
    
    //================================
    
    func onClassifiedDetails() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ClassifiedDetailsViewController") as! ClassifiedDetailsViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func onEditClassified() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditClassifiedViewController") as! EditClassifiedViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func unwindPreviewClassified(segue: UIStoryboardSegue) {
        
    }
    
    //===============================
    
    func onMessageDetails() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageDescriptionViewController") as! MessageDescriptionViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    //===============================
    
    func onEventDetails() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsViewController") as! EventDetailsViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func onPastEventDetails() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "PastEventDetailsViewController") as! PastEventDetailsViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    //===============================
    
    func onProfileView() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
