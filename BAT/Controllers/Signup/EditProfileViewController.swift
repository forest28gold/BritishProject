//
//  EditProfileViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import Parse

class EditProfileViewController: Controller, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var btnLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var btnRightMargin: NSLayoutConstraint!
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var departmentLabel: UILabel!
    @IBOutlet var departmentButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var cellPhoneTextField: UITextField!
    @IBOutlet var mainView: UIView!
    @IBOutlet var dataView: UIView!
    @IBOutlet var dataPickerView: UIPickerView!
    @IBOutlet var startButton: UIButton!
    
    var pickerController = UIImagePickerController()
    
    var is_changed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.loadLayout()
        self.initLoadDepartmentData()
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
            self.startButton.layer.cornerRadius = CGFloat(BUTTON_RADIUS)
            self.view.layoutIfNeeded()
        }
        
        nameTextField.isEnabled = false
        departmentButton.isEnabled = false
        emailTextField.isEnabled = false
        phoneTextField.isEnabled = false
        cellPhoneTextField.isEnabled = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
        self.mainView.isUserInteractionEnabled = true
        self.mainView.addGestureRecognizer(tap)
        
//        let tapPhoto: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapPhoto(recognizer:)))
//        self.profileImageView.isUserInteractionEnabled = true
//        self.profileImageView.addGestureRecognizer(tapPhoto)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if Config.isEditProfile {
            let photoUrl = Config.onCheckUserFileNull(object: Config.currentUser, key: "image")
            profileImageView?.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(named: "ic_profile"))
            
            let strName = Config.onCheckUserStringNull(object: Config.currentUser, key: "name")
            nameTextField.text = strName.capitalized(with: NSLocale.current)
            let userDepartmentArray = Config.onCheckUserArrayNull(object: Config.currentUser, key: "department")
            departmentLabel.text = self.parseDepartmentData(objectIdArray: userDepartmentArray)
            emailTextField.text = Config.currentUser.username
            phoneTextField.text = Config.onCheckUserStringNull(object: Config.currentUser, key: "phone")
            cellPhoneTextField.text = Config.onCheckUserStringNull(object: Config.currentUser, key: "phoneCell")
            
            startButton.setTitle(localized("edit_profile_save"), for: .normal)
        } else {
//            profileImageView?.image = UIImage(named: "ic_profile")
            emailTextField.text = Config.verifyEmail
            
            let photoUrl = Config.onCheckUserFileNull(object: Config.currentUser, key: "image")
            profileImageView?.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(named: "ic_profile"))
            
            let strName = Config.onCheckUserStringNull(object: Config.currentUser, key: "name")
            nameTextField.text = strName.capitalized(with: NSLocale.current)
            let userDepartmentArray = Config.onCheckUserArrayNull(object: Config.currentUser, key: "department")
            departmentLabel.text = self.parseDepartmentData(objectIdArray: userDepartmentArray)
            emailTextField.text = Config.currentUser.username
            phoneTextField.text = Config.onCheckUserStringNull(object: Config.currentUser, key: "phone")
            cellPhoneTextField.text = Config.onCheckUserStringNull(object: Config.currentUser, key: "phoneCell")
            
            startButton.setTitle(localized("edit_profile_start"), for: .normal)
        }
        
        if nameTextField.text == "" {
            nameTextField.font = UIFont(name: "SanFranciscoText-Regular", size: 16)
        } else {
            nameTextField.font = UIFont(name: "SanFranciscoText-Bold", size: 21)
        }
        
        if departmentLabel.text == localized("edit_profile_department") {
            departmentLabel.textColor = colorHEX("D8D8D8")
        } else {
            departmentLabel.textColor = colorHEX("94989A")
        }
        
        emailTextField.isEnabled = false
    }
    
    func parseDepartmentData(objectIdArray: [String]) -> String {
        
        var strDepartment = ""
        var idCount = 0
        let objectCount = objectIdArray.count
        
        if objectCount > 0 {
            for objectId in objectIdArray {
                for object in Config.departmentArray {
                    if objectId == object.objectId {
                        var department = ""
                        if Config.currentLocale == Config.LOCALE_ES {
                            department = Config.onCheckStringNull(object: object, key: "name_es")
                        } else {
                            department = Config.onCheckStringNull(object: object, key: "name")
                        }
                        
                        if idCount == 0 {
                            strDepartment = department
                        } else if objectCount > 1 && idCount == objectCount - 1 {
                            strDepartment = strDepartment + localized("edit_profile_and") + department
                        } else {
                            strDepartment = strDepartment + ", " + department
                        }
                        idCount = idCount + 1
                    }
                }
            }
        }
        return strDepartment
    }
    
    func initLoadDepartmentData() {
        
        if Config.departmentArray.count > 0 {
            
        } else {
            let query = PFQuery(className: Const.ParseClass.DepartmentClass)
            if Config.currentLocale == Config.LOCALE_ES {
                query.order(byAscending: "name_es")
            } else {
                query.order(byAscending: "name")
            }
            query.findObjectsInBackground (block: { (objects, error) in
                if error == nil {
                    if let objects = objects {
                        Config.departmentArray.removeAll()
                        for object in objects {
                            Config.departmentArray.append(object)
                        }
                        self.dataPickerView.reloadAllComponents()
                    }
                }
            })
        }
    }
    
    // MARK: UITapGestureRecognizer

    @objc func handleTapFrom(recognizer : UITapGestureRecognizer) {
        dismissKeyboard()
        closeAnimationView(dataView)
    }
    
    // MARK: UITextField Delegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            phoneTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            phoneTextField.becomeFirstResponder()
        } else if textField == phoneTextField {
            cellPhoneTextField.becomeFirstResponder()
        } else if textField == cellPhoneTextField {
            dismissKeyboard()
        }
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        closeAnimationView(dataView)
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        closeAnimationView(dataView)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            nameTextField.font = UIFont(name: "SanFranciscoText-Regular", size: 16)
        } else {
            nameTextField.font = UIFont(name: "SanFranciscoText-Bold", size: 21)
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: UIView Animation
    
    func showAnimationView(_ mView: UIView) {
        mView.isHidden = false
        mView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            mView.alpha = 1
            mView.frame = CGRect(x: mView.frame.origin.x, y: self.view.frame.size.height - mView.frame.size.height, width: mView.frame.size.width, height: mView.frame.size.height)
        }, completion: {(_ finished: Bool) -> Void in
            if finished {
                
            }
        })
    }
    
    func closeAnimationView(_ mView: UIView) {
        UIView.animate(withDuration: 0.4, animations: {() -> Void in
            mView.alpha = 0
            mView.frame = CGRect(x: mView.frame.origin.x, y: self.view.frame.size.height, width: mView.frame.size.width, height: mView.frame.size.height)
        }, completion: {(_ finished: Bool) -> Void in
            if finished {
                mView.isHidden = true
            }
        })
    }
    
    // MARK: UIPickerView Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Config.departmentArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if Config.currentLocale == Config.LOCALE_ES {
            return Config.onCheckStringNull(object: Config.departmentArray[row], key: "name_es")
        } else {
            return Config.onCheckStringNull(object: Config.departmentArray[row], key: "name")
        }
        
    }
    
    @IBAction func cancelPickerAction(_ sender: Any) {
        closeAnimationView(dataView)
    }
    
    @IBAction func donePickerAction(_ sender: Any) {
        closeAnimationView(dataView)
        departmentLabel.textColor = colorHEX("94989A")
        if Config.currentLocale == Config.LOCALE_ES {
            departmentLabel.text = Config.onCheckStringNull(object: Config.departmentArray[self.dataPickerView.selectedRow(inComponent: 0)], key: "name_es")
        } else {
            departmentLabel.text = Config.onCheckStringNull(object: Config.departmentArray[self.dataPickerView.selectedRow(inComponent: 0)], key: "name")
        }
    }
    
    // MARK: Camera Action
    
    @objc func handleTapPhoto(recognizer : UITapGestureRecognizer) {
        self.editProfile()
    }
    
    func editProfile() {
        dismissKeyboard()
        closeAnimationView(dataView)
        
        let alert = UIAlertController(title: localized("edit_profile_choose_from"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: localized("edit_profile_camera"), style: .default , handler:{ (UIAlertAction)in
            self.openPhotoCamera()
        }))
        alert.addAction(UIAlertAction(title: localized("edit_profile_photo_library"), style: .default , handler:{ (UIAlertAction)in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: localized("generic_cancel"), style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func openPhotoCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            pickerController.delegate = self
            self.pickerController.sourceType = UIImagePickerControllerSourceType.camera
            pickerController.mediaTypes = [kUTTypeImage as String]
            pickerController.allowsEditing = false
            self.present(self.pickerController, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            pickerController.mediaTypes = [kUTTypeImage as String]
            pickerController.allowsEditing = false
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: UIImagePickerController Delegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var imageView = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView = imageView.fixOrientation()
        
        profileImageView.image = imageView.resizeImage(image: imageView, newWidth: 400)
        self.is_changed = true
        
        dismiss(animated:true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        moveNext()
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        self.editProfile()
    }
    
    @IBAction func departmentButtonPressed(_ sender: Any) {
        dismissKeyboard()
        
        if Config.departmentArray.count > 0 {
            showAnimationView(dataView)
        } else {
            
            self.showLoading(status: localized("generic_wait"))
            
            let query = PFQuery(className: Const.ParseClass.DepartmentClass)
            if Config.currentLocale == Config.LOCALE_ES {
                query.order(byAscending: "name_es")
            } else {
                query.order(byAscending: "name")
            }
            query.findObjectsInBackground (block: { (objects, error) in
                
                self.stopLoading()
                
                if error == nil {
                    if let objects = objects {
                        Config.departmentArray.removeAll()
                        for object in objects {
                            Config.departmentArray.append(object)
                        }
                        self.dataPickerView.reloadAllComponents()
                        self.showAnimationView(self.dataView)
                    }
                }
            })
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
//        if nameTextField.text == "" {
//            self.showAlert(message: localized("edit_profile_name_error"))
//            return
//        } else if departmentLabel.text == localized("edit_profile_department") {
//            self.showAlert(message: localized("edit_profile_department_error"))
//            return
//        } else if emailTextField.text == "" {
//            self.showAlert(message: localized("login_email_error"))
//            return
//        } else if !Config.validateEmail(enteredEmail: emailTextField.text!) {
//            self.showAlert(message: localized("login_email_format_error"))
//            return
//        } else if phoneTextField.text == "" {
//            self.showAlert(message: localized("edit_profile_phone_error"))
//            return
//        } else if cellPhoneTextField.text == "" {
//            self.showAlert(message: localized("edit_profile_cell_phone_error"))
//            return
//        }
        
        if profileImageView.image == UIImage(named: "ic_profile") {
            self.showAlert(message: localized("edit_profile_photo_error"))
            return
        }
        
        dismissKeyboard()
        
        if self.is_changed {
            
            self.showLoading(status: localized("generic_wait"))
            
            let random = Config.randomNumber(length: 8)
            let fileName = random + ".png"
            let imageData = UIImagePNGRepresentation(profileImageView.image!)
            let imageFile = PFFile(name:fileName, data:imageData!)
            imageFile?.saveInBackground(block: { (success, error) in
                if success {
                    Config.currentUser["image"] = imageFile
                    Config.currentUser.saveInBackground(block: { (success, error) in
                        self.stopLoading()
                        if success {
                            self.moveNext()
                        } else {
                            self.showAlert(message: localized("edit_failed"))
                            return
                        }
                    })
                } else {
                    self.stopLoading()
                    self.showAlert(message: localized("edit_failed"))
                    return
                }
            })
        } else {
            self.moveNext()
        }
    }
    
    func moveNext() {
        
        if Config.isEditProfile {
            self.navigationController?.popViewController(animated: true)
        } else {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "welcome")
            
//            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//            self.navigationController?.pushViewController(nextViewController, animated: true)
            
            let root = self.storyboard?.instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
            let home = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController")
            root.setViewControllers([home!], animated: true)
            UIApplication.shared.keyWindow?.rootViewController = root
        }
    }
}
