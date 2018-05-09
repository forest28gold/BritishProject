//
//  TabDirectoryViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse

class TabDirectoryViewController: Controller, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var directoryTableView: UITableView!
    
    var directories = [PFUser]()
    
    var is_load = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
        loadDirectoryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if is_load {
            self.refreshDirectoryData()
        }
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
        for subView in searchBar.subviews {
            for subsubView in subView.subviews {
                if let textField = subsubView as? UITextField {
                    textField.backgroundColor = colorHEX("000000").withAlphaComponent(0.08)
                    textField.font = UIFont(name: "SanFranciscoText-Regular", size: 15)
                    textField.textColor = colorHEX("8E8E93")
                }
            }
        }
        
        self.searchBar.delegate = self
    }
    
    // MARK: Load Directory Data
    
    func loadDirectoryData() {
        
        Config.directoryArray.removeAll()
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFUser.query()
        query?.order(byAscending: "name")
        query?.whereKey("isAdmin", equalTo: false)
        query?.whereKey("objectId", notEqualTo: Config.currentUser.objectId!)
        query?.includeKey("userStatus")
        query?.limit = QUERY_LIMIT
        query?.findObjectsInBackground (block: { (objects, error) in
            
            self.stopLoading()
            self.is_load = true
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let statusObject = object["userStatus"] as? PFObject
                        if statusObject != nil {
                            let status = Config.onCheckStringNull(object: statusObject!, key: "status")
                            if status.lowercased() == "active" || status.lowercased() == "inactive" {
                                Config.directoryArray.append(object as! PFUser)
                            }
                        }
                    }
                }
                Config.directoryArray.sort(by: { (first: PFUser, second: PFUser) -> Bool in
                    let name1 = Config.onCheckUserStringNull(object: first, key: "name")
                    let name2 = Config.onCheckUserStringNull(object: second, key: "name")
                    return name1.lowercased() < name2.lowercased()
                })
                self.directories = Config.directoryArray
                self.directoryTableView.reloadData()
            }
        })
    }
    
    func refreshDirectoryData() {
        
        let query = PFUser.query()
        query?.order(byAscending: "name")
        query?.whereKey("isAdmin", equalTo: false)
        query?.whereKey("objectId", notEqualTo: Config.currentUser.objectId!)
        query?.includeKey("userStatus")
        query?.limit = QUERY_LIMIT
        query?.findObjectsInBackground (block: { (objects, error) in
            if error == nil {
                if let objects = objects {
                    Config.directoryArray.removeAll()
                    self.directories.removeAll()
                    for object in objects {
                        let statusObject = object["userStatus"] as? PFObject
                        if statusObject != nil {
                            let status = Config.onCheckStringNull(object: statusObject!, key: "status")
                            if status.lowercased() == "active" || status.lowercased() == "inactive" {
                                Config.directoryArray.append(object as! PFUser)
                            }
                        }
                    }
                    Config.directoryArray.sort(by: { (first: PFUser, second: PFUser) -> Bool in
                        let name1 = Config.onCheckUserStringNull(object: first, key: "name")
                        let name2 = Config.onCheckUserStringNull(object: second, key: "name")
                        return name1.lowercased() < name2.lowercased()
                    })
                    self.filterDirectoryData(searchText: self.searchBar.text!)
                }
                self.directoryTableView.reloadData()
            }
        })
    }
    
    // MARK: UISearchBar
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterDirectoryData(searchText: searchText)
        self.directoryTableView.reloadData()
    }
    
    func filterDirectoryData(searchText: String) {
        if searchText == "" {
            self.directories = Config.directoryArray
        } else {
            self.directories = Config.directoryArray.filter({ (userObject) -> Bool in
                let username = Config.onCheckUserStringNull(object: userObject, key: "name")
                let departmentArray = Config.onCheckUserArrayNull(object: userObject, key: "department")
                let department = self.parseDepartmentData(objectIdArray: departmentArray).replacingOccurrences(of: localized("edit_profile_and"), with: " ")
                let searchTemp = username + " " + department.replacingOccurrences(of: ", ", with: " ")
                let tmp: NSString = searchTemp as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
        }
    }
    
    // MARK: Action

    @IBAction func profileButtonPressed(_ sender: Any) {
        Config.isEditProfile = true
        Config.tabBarCtrl?.onSeeMyProfile()
    }
    
    // MARK: UITableView Delegate
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.directories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryCell", for: indexPath as IndexPath)
        
        let profileImage = cell.viewWithTag(1) as? UIImageView
        let nameLable = cell.viewWithTag(2) as? UILabel
        let bioLable = cell.viewWithTag(3) as? UILabel
        
        profileImage?.layer.cornerRadius = (profileImage?.frame.size.height)! / 2
        
        let userData = self.directories[indexPath.row]
        
        let photoUrl = Config.onCheckUserFileNull(object: userData, key: "image")
        profileImage?.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(named: "ic_profile"))
        
        let strName = Config.onCheckUserStringNull(object: userData, key: "name")
        nameLable?.text = strName.capitalized(with: NSLocale.current)
        let userDepartmentArray = Config.onCheckUserArrayNull(object: userData, key: "department")
        bioLable?.text = self.parseDepartmentData(objectIdArray: userDepartmentArray)
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        Config.directoryData = self.directories[indexPath.row]
        Config.tabBarCtrl?.onProfileView()
    }
    
    //-----------------------
    
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
}
