//
//  ResetPasswordViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: Controller, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    
    var is_send = false

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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: UITapGestureRecognizer
    
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    // MARK: UITextField Delegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            dismissKeyboard()
        }
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func resetButtonPressed(_ sender: Any) {
        
        if emailTextField.text == "" {
            self.showAlert(message: localized("login_email_error"))
            return
        } else if !Config.validateEmail(enteredEmail: emailTextField.text!) {
            self.showAlert(message: localized("login_email_format_error"))
            return
        }
        
        dismissKeyboard()
        
        resetPassword()
        
//        if !self.is_send {
//            if emailTextField.text == "" {
//                self.showAlert(message: localized("login_email_error"))
//                return
//            } else if !Config.validateEmail(enteredEmail: emailTextField.text!) {
//                self.showAlert(message: localized("login_email_format_error"))
//                return
//            }
//
//            dismissKeyboard()
//
//            resetPassword()
//        } else {
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    func resetPassword() {
        
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFUser.query()
        query?.whereKey("email", equalTo: emailTextField.text!)
        query?.whereKey("isAdmin", equalTo: false)
        query?.includeKey("userStatus")
        query?.getFirstObjectInBackground(block: { (object, error) in
            if error == nil {
                let statusObject = object!["userStatus"] as! PFObject
                let status = Config.onCheckStringNull(object: statusObject, key: "status")
                if status.lowercased() == "active" {
                    
                    let email = self.emailTextField.text!
                    let statusObjectId = statusObject.objectId
                    PFCloud.callFunction(inBackground: "sendResetEmail", withParameters: ["emailAddress" : email as Any, "statusObjectId" : statusObjectId as Any, "lang" : Config.currentLocale as Any], block: { (respond, error) in
                        PFUser.logOut()
                        if error == nil {
                            self.is_send = true
                            print("Send email successfully ", respond.debugDescription)
                            self.showSuccess(success: localized("reset_password_sent"))
                        } else {
                            print("Send email is failed ", error.debugDescription)
                            self.showError(err: localized("reset_password_failed"))
                        }
                    })
                } else if status.lowercased() == "removed" {
                    self.stopLoading()
                    PFUser.logOut()
                    self.showAlert(message: localized("login_removed"))
                    return
                } else {
                    self.stopLoading()
                    PFUser.logOut()
                    self.showAlert(message: localized("login_failed"))
                    return
                }
            } else {
                self.stopLoading()
                PFUser.logOut()
                self.showAlert(message: localized("signup_failed"))
                return
            }
        })
    }
}
