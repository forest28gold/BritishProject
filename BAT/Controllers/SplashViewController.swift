//
//  SplashViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import Foundation
import Parse

class SplashViewController: Controller {
    
    var isViewDisplayed: Bool = false {
        didSet {
            self.showAlertWhenReady()
        }
    }
    
    var popupShouldShow: Bool = false {
        didSet {
            self.showAlertWhenReady()
        }
    }
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initLayout()
        self.initLoadDepartment()
        self.initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadNavItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isViewDisplayed = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    
    /// Load navigation item
    func loadNavItem() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: Layout
    
    /// Init any UI Related Content
    func initLayout() {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // MARK: Data Management
    
    func initLoadDepartment() {
        
        let query = PFQuery(className: Const.ParseClass.DepartmentClass)
        if Config.currentLocale == Config.LOCALE_ES {
            query.order(byAscending: "name_es")
        } else {
            query.order(byAscending: "name")
        }
        query.findObjectsInBackground (block: { (objects, error) in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        Config.departmentArray.append(object)
                    }
                }
            }
        })
    }
    
    /// Perform initial data loading
    func initData() {
        Queue.userInitiated.async {
            do {
                delay(delay: .seconds(1), {
                    // Do your loading stuff here and throw an error if needed
                    let defaults = UserDefaults.standard
                    if defaults.bool(forKey: "welcome") {
                        self.login()
                    } else {
                        self.goWelcome()
                    }
                })
            }
        }
    }
    
    func login() {
        Queue.main.async {
            let email = Config.onCheckDefaultStringNull(key: "email")
            let password = Config.onCheckDefaultStringNull(key: "password")
            
            let query = PFUser.query()
            query?.whereKey("email", equalTo: email)
            query?.whereKey("isAdmin", equalTo: false)
            query?.includeKey("userStatus")
            query?.getFirstObjectInBackground(block: { (object, error) in
                if error == nil {
                    let statusObject = object!["userStatus"] as! PFObject
                    let status = Config.onCheckStringNull(object: statusObject, key: "status")
                    let userPassword = Config.onCheckStringNull(object: statusObject, key: "password")
                    if status.lowercased() == "active" {
                        PFUser.logInWithUsername(inBackground: email, password: PASSWORD_BAT, block: { (user, error) in
                            if error == nil {
                                if password == userPassword {
                                    Queue.main.async {
                                        do {
                                            try Config.currentUser = user?.fetch()
                                        } catch {
                                            
                                        }
                                        if Config.deviceId != "" {
                                            statusObject["deviceId"] = Config.deviceId
                                            statusObject.saveInBackground()
                                        }
                                    }
                                    self.goMain()
                                } else {
                                    self.showAlertError(message: localized("login_invalid"))
                                }
                            } else {
                                self.showAlertError(message: localized("login_invalid"))
                            }
                        })
                    } else if status.lowercased() == "removed" {
                        self.showAlertError(message: localized("login_removed"))
                    } else {
                        self.showAlertError(message: localized("login_failed"))
                    }
                } else {
                    self.showAlertError(message: localized("signup_failed"))
                }
            })
        }
    }
    
    func showAlertWhenReady() {
        Queue.main.async {
            if self.isViewDisplayed && self.popupShouldShow {
                let alert = UIAlertController(title: localized("splash_setup_error"), message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: localized("splash_setup_retry"), style: .default, handler: { (_) in
                    self.initData()
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showAlertError(message: String) {
        PFUser.logOut()
        
        Queue.main.async {
            let alert = UIAlertController(title: localized("generic_alert"), message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: localized("generic_ok"), style: .default, handler: { (_) in
                self.goWelcome()
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func goWelcome() {
        Queue.main.async {
//            self.navigationController?.setNavigationBarHidden(true, animated: false)
//            self.performSegue(withIdentifier: Route.routeSplash.to(.routeWelcome), sender: self)
            
//            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
//            self.navigationController?.pushViewController(nextViewController, animated: true)
            
            let root = self.storyboard?.instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
            let home = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController")
            root.setViewControllers([home!], animated: true)
            UIApplication.shared.keyWindow?.rootViewController = root
        }
    }
    
    func goMain() {
        Queue.main.async {
//            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//            self.navigationController?.pushViewController(nextViewController, animated: true)
            
            let root = self.storyboard?.instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
            let home = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController")
            root.setViewControllers([home!], animated: true)
            UIApplication.shared.keyWindow?.rootViewController = root
        }
    }
}
