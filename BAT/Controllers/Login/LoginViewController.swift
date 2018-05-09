//
//  LoginViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class LoginViewController: Controller, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var isPasswordShow : Bool!

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
        
        isPasswordShow = false
    }
    
    // MARK: UITapGestureRecognizer
    
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    // MARK: UITextField Delegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            dismissKeyboard()
        }
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: MFMailCompose Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func passwordButtonPressed(_ sender: Any) {
        if isPasswordShow {
            passwordTextField.isSecureTextEntry = true
            isPasswordShow = false
        } else {
            passwordTextField.isSecureTextEntry = false
            isPasswordShow = true
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func connectionButtonPressed(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([CONNECTION_EMAIL])
            mail.setCcRecipients([CONNECTION_CC_EMAIL])
            mail.setSubject(localized("connection_issue"))
            mail.setMessageBody("", isHTML: false)
            self.present(mail, animated: true)
        }
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if emailTextField.text == "" {
            self.showAlert(message: localized("login_email_error"))
            return
        } else if !Config.validateEmail(enteredEmail: emailTextField.text!) {
            self.showAlert(message: localized("login_email_format_error"))
            return
        } else if passwordTextField.text == "" {
            self.showAlert(message: localized("login_password_error"))
            return
        }
        
        dismissKeyboard()
        
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFUser.query()
        query?.whereKey("email", equalTo: emailTextField.text!)
        query?.whereKey("isAdmin", equalTo: false)
        query?.includeKey("userStatus")
        query?.getFirstObjectInBackground(block: { (object, error) in
            if error == nil {
                let statusObject = object!["userStatus"] as! PFObject
                let status = Config.onCheckStringNull(object: statusObject, key: "status")
                let userPassword = Config.onCheckStringNull(object: statusObject, key: "password")
                if status.lowercased() == "active" {
                    
                    PFUser.logInWithUsername(inBackground: self.emailTextField.text!, password: PASSWORD_BAT, block: { (user, error) in
                        self.stopLoading()
                        if error == nil {
                            if self.passwordTextField.text! == userPassword {
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
                                
                                let defaults = UserDefaults.standard
                                defaults.set(true, forKey: "welcome")
                                defaults.set(self.emailTextField.text!, forKey: "email")
                                defaults.set(self.passwordTextField.text!, forKey: "password")
                                
                                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                                self.navigationController?.pushViewController(nextViewController, animated: true)
                                
                                return
                            } else {
                                PFUser.logOut()
                                self.showAlert(message: localized("login_invalid"))
                                return
                            }
                        } else {
                            PFUser.logOut()
                            self.showAlert(message: localized("login_invalid"))
                            return
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
