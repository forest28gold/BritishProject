//
//  VerifyEmailViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse

class VerifyEmailViewController: Controller {
    
    @IBOutlet weak var btnLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var btnRightMargin: NSLayoutConstraint!
    
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loadLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopLoading()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    func loadLayout() {
        
        iPhoneX {
            self.btnLeftMargin.constant += CGFloat(BUTTON_MARGIN)
            self.btnRightMargin.constant += CGFloat(BUTTON_MARGIN)
            self.continueButton.layer.cornerRadius = CGFloat(BUTTON_RADIUS)
            self.view.layoutIfNeeded()
        }
        
        emailLabel.text = localized("verify_sent_code") + "\n\"" + Config.verifyEmail + "\""
    }
    
    // MARK: Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        Queue.main.async {
            PFUser.logOut()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFUser.query()
        query?.whereKey("email", equalTo: Config.verifyEmail)
        query?.whereKey("isAdmin", equalTo: false)
        query?.includeKey("userStatus")
        query?.getFirstObjectInBackground(block: { (object, error) in
            if error == nil {
                let statusObject = object!["userStatus"] as! PFObject
                let status = Config.onCheckStringNull(object: statusObject, key: "status")
                if status.lowercased() == "active" {
                    
                    self.stopLoading()
                    
                    let defaults = UserDefaults.standard
                    defaults.set(true, forKey: "welcome")
                    
                    Queue.main.async {
                        statusObject["deviceId"] = Config.deviceId
                        statusObject.saveInBackground()
                    }
                    
                    Config.isEditProfile = false
                    let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                    
                    return
                } else {
                    self.showError(err: localized("verify_error"))
                    return
                }
            } else {
                self.showError(err: localized("verify_error"))
                return
            }
        })
    }
}
