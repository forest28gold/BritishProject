//
//  ProfileViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import MessageUI
import Contacts
import ContactsUI
import Parse

class ProfileViewController: Controller, MFMailComposeViewControllerDelegate, CNContactViewControllerDelegate {
    
    @IBOutlet weak var btnLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var btnRightMargin: NSLayoutConstraint!
    
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var cellPhoneLabel: UILabel!
    
    var strName = ""
    var strEmail = ""
    var strDepartment = ""
    var strPhone = ""
    var strPhoneCell = ""
    var strPhotoUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadNavItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    
    // Load navigation item
    func loadNavItem() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: Layout
    
    func loadLayout() {
        
        iPhoneX {
            self.btnLeftMargin.constant += CGFloat(BUTTON_MARGIN)
            self.btnRightMargin.constant += CGFloat(BUTTON_MARGIN)
            self.copyButton.layer.cornerRadius = CGFloat(BUTTON_RADIUS)
            self.view.layoutIfNeeded()
        }
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2

        strPhotoUrl = Config.onCheckUserFileNull(object: Config.directoryData, key: "image")
        strName = Config.onCheckUserStringNull(object: Config.directoryData, key: "name")
        strEmail = Config.directoryData.username!
        strPhone = Config.onCheckUserStringNull(object: Config.directoryData, key: "phone")
        strPhoneCell = Config.onCheckUserStringNull(object: Config.directoryData, key: "phoneCell")
        
        profileImage.sd_setImage(with: URL(string: strPhotoUrl), placeholderImage: UIImage(named: "ic_profile"))
        
        nameLabel.text = strName.capitalized(with: NSLocale.current)
        emailLabel.text = strEmail
        phoneLabel.text = strPhone
        cellPhoneLabel.text = strPhoneCell
        
        let userDepartmentArray = Config.onCheckUserArrayNull(object: Config.directoryData, key: "department")
        strDepartment = self.parseDepartmentData(objectIdArray: userDepartmentArray)
        bioLabel.text = strDepartment
    }
    
    func parseDepartmentData(objectIdArray: [String]) -> String {
        
        var departments = ""
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
                            departments = department
                        } else if objectCount > 1 && idCount == objectCount - 1 {
                            departments = departments + localized("edit_profile_and") + department
                        } else {
                            departments = departments + ", " + department
                        }
                        idCount = idCount + 1
                    }
                }
            }
        }
        return departments
    }
    
    // MARK: MFMailComposeViewController Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([strEmail])
            mail.setSubject("")
            mail.setMessageBody("", isHTML: false)
            self.present(mail, animated: true)
        }
    }
    
    @IBAction func phoneButtonPressed(_ sender: Any) {
        let phoneNumber = strPhone
        if let url = NSURL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    @IBAction func cellPhoneButtonPressed(_ sender: Any) {
        let phoneNumber = strPhoneCell
        if let url = NSURL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        
        var firstName = ""
        var lastName = ""
        
        if strName.contains(" ") {
            firstName = strName.components(separatedBy: " ")[0]
            lastName = strName.components(separatedBy: " ")[1]
        } else {
            firstName = strName
        }
        
        let con = CNMutableContact()
        con.givenName = firstName.capitalized(with: NSLocale.current)
        con.familyName = lastName.capitalized(with: NSLocale.current)
        con.departmentName = strDepartment
        if strPhotoUrl != "" {
            let imageData = UIImagePNGRepresentation(profileImage.image!)
            con.imageData = imageData
        }
        let workEmail = CNLabeledValue(label: CNLabelWork, value: strEmail as NSString)
        con.emailAddresses = [workEmail]
        con.phoneNumbers.append(CNLabeledValue(
            label: CNLabelHome, value: CNPhoneNumber(stringValue: strPhone)))
        con.phoneNumbers.append(CNLabeledValue(
            label: CNLabelWork, value: CNPhoneNumber(stringValue: strPhoneCell)))
        
        let unkvc = CNContactViewController(forUnknownContact: con)
        unkvc.message = ""
        unkvc.contactStore = CNContactStore()
        unkvc.delegate = self
        unkvc.allowsEditing = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(unkvc, animated: true)
    }
    
    //MARK: CNContactViewControllerDelegate methods
    // Dismisses the new-person view controller.
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
}
