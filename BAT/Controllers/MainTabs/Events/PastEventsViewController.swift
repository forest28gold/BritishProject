//
//  PastEventsViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import PullToRefresh
import Parse

class PastEventsViewController: Controller, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var eventView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var eventTableView: UITableView!
    
    var eventArray = [PFObject]()
    var is_load = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
        loadEventData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    func loadLayout() {        
        eventTableView.addPullToRefresh(PullToRefresh()) { [weak self] in
            if (self?.is_load)! {
                self?.refreshEventData()
            }
        }
    }
    
    // MARK: Load Data
    
    func loadEventData() {
        let currentDate = NSDate()
        
        self.showLoading(status: localized("generic_wait"))

        let query = PFQuery(className: Const.ParseClass.EventClass)
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("isOpen", equalTo:false)
        query.whereKey("date", lessThan: currentDate)
        query.order(byDescending: "date")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.stopLoading()
            self.is_load = true
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let isDepartment = object["isDepartment"] as! Bool
                        if isDepartment {
                            let departmentArray = Config.onCheckArrayNull(object: object, key: "department")
                            let userDepartmentArray = Config.onCheckUserArrayNull(object: Config.currentUser, key: "department")
                            if self.checkContainsObjectId(userIdArray: userDepartmentArray, departmentArray: departmentArray) {
                                self.eventArray.append(object)
                            }
                        } else {
                            self.eventArray.append(object)
                        }
                    }
                    
                    if self.eventArray.count > 0 {
                        self.eventTableView.reloadData()
                        self.emptyView.isHidden = true
                        self.eventView.isHidden = false
                    } else {
                        self.emptyView.isHidden = false
                        self.eventView.isHidden = true
                    }
                } else {
                    self.emptyView.isHidden = false
                    self.eventView.isHidden = true
                }
            } else {
                self.emptyView.isHidden = false
                self.eventView.isHidden = true
            }
        })
    }
    
    func checkContainsObjectId(userIdArray: [String], departmentArray: [String]) -> Bool {
        for objectId in userIdArray {
            for departmentId in departmentArray {
                if objectId == departmentId {
                    return true
                }
            }
        }
        return false
    }
    
    func refreshEventData() {
        
        let currentDate = NSDate()
        
        let query = PFQuery(className: Const.ParseClass.EventClass)
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("isOpen", equalTo:false)
        query.whereKey("date", lessThan: currentDate)
        query.order(byDescending: "date")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in

            self.eventTableView.endRefreshing(at: .top)
            self.eventArray.removeAll()
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let isDepartment = object["isDepartment"] as! Bool
                        if isDepartment {
                            let departmentArray = Config.onCheckArrayNull(object: object, key: "department")
                            let userDepartmentArray = Config.onCheckUserArrayNull(object: Config.currentUser, key: "department")
                            if self.checkContainsObjectId(userIdArray: userDepartmentArray, departmentArray: departmentArray) {
                                self.eventArray.append(object)
                            }
                        } else {
                            self.eventArray.append(object)
                        }
                    }
                    
                    if self.eventArray.count > 0 {
                        
                        UIView.performWithoutAnimation {
                            let range = NSMakeRange(0, self.eventTableView.numberOfSections)
                            let sections = NSIndexSet(indexesIn: range)
                            self.eventTableView.reloadSections(sections as IndexSet, with: .none)
                        }

                        self.emptyView.isHidden = true
                        self.eventView.isHidden = false
                    } else {
                        self.emptyView.isHidden = false
                        self.eventView.isHidden = true
                    }
                } else {
                    self.emptyView.isHidden = false
                    self.eventView.isHidden = true
                }
            } else {
                self.emptyView.isHidden = false
                self.eventView.isHidden = true
            }
        })
    }
    
    // MARK: Action

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func emptybackButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UITableView Delegate
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath as IndexPath)

        let nameLable = cell.viewWithTag(1) as? UILabel
        let timeLable = cell.viewWithTag(2) as? UILabel
        
        let eventObject = self.eventArray[indexPath.row]
        let name = Config.onCheckStringNull(object: eventObject, key: "title")
        let eventDate = eventObject["date"] as! Date
        
        nameLable?.text = name
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy, hh:mm a"
        let time = formatter.string(from: eventDate)
        timeLable?.text = time.replacingOccurrences(of: ", ", with: localized("event_at"))

        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        Config.pastEventData = self.eventArray[indexPath.row]
        Config.tabBarCtrl?.onPastEventDetails()
    }
}
