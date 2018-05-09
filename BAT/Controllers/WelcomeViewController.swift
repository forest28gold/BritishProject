//
//  WelcomeViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit

class WelcomeViewController: Controller, UIGestureRecognizerDelegate {

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
    
    // MARK: Layout
    
    func loadLayout() {
        
        let pre = Locale.preferredLanguages[0]
        if pre.range(of:"es") != nil {
            Config.currentLocale = Config.LOCALE_ES
        } else {
            Config.currentLocale = Config.LOCALE_EN
        }
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
    
    // MARK: Actions
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
}
