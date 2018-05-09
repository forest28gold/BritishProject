//
//  TabEventsViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import PullToRefresh
import Parse

class TabEventsViewController: Controller, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var eventView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var eventTableView: UITableView!
    
    var eventSections = [String]()
    var eventArray = [[EventData]]()
    
    var is_load = false
    
    var subEventArray = [EventData]()
    var isLiveAdded = false, isNextAdded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
        loadEventData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if is_load {
            self.refreshEventData()
        }
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
        
        self.showLoading(status: localized("generic_wait"))

        let query = PFQuery(className: Const.ParseClass.EventClass)
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("isOpen", equalTo:true)
        query.order(byAscending: "date")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.stopLoading()
            self.is_load = true
            
            if error == nil {
                if let objects = objects {
                    
                    self.subEventArray.removeAll()
                    self.isLiveAdded = false
                    self.isNextAdded = false
                    
                    for object in objects {
                        let isDepartment = object["isDepartment"] as! Bool
                        if isDepartment {
                            let departmentArray = Config.onCheckArrayNull(object: object, key: "department")
                            let userDepartmentArray = Config.onCheckUserArrayNull(object: Config.currentUser, key: "department")
                            if self.checkContainsObjectId(userIdArray: userDepartmentArray, departmentArray: departmentArray) {
                                self.filterEventData(object: object)
                            }
                        } else {
                            self.filterEventData(object: object)
                        }
                    }
                    
                    if self.eventSections.count > 0 {
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
    
    func filterEventData(object: PFObject) {
        
        let date = object["date"] as? Date
        if date != nil {
            let title = Config.onCheckStringNull(object: object, key: "title")
            let question = Config.onCheckStringNull(object: object, key: "question")
            let streamingUrl = Config.onCheckStringNull(object: object, key: "streamingUrl")
            var is_read = false
            if DBManager.readEvent(email: Config.currentUser.objectId!, eventId: object.objectId!) {
                is_read = true
            }
            
            let eventData = EventData.init(objectId: object.objectId!, eventObject: object, title: title, date: date!, question: question, streamingUrl: streamingUrl, is_read: is_read)
            
            let currentDate = NSDate()
            let eventDate = object["date"] as! Date
            if eventDate <= (currentDate as Date) {
                if !isLiveAdded {
                    isLiveAdded = true
                    self.eventSections.append(localized("event_live_now"))
                    subEventArray.removeAll()
                    
                    subEventArray.append(eventData)
                    self.eventArray.append(subEventArray)
                } else {
                    subEventArray.append(eventData)
                    
                    self.eventArray.remove(at: self.eventSections.count - 1)
                    self.eventArray.insert(subEventArray, at: self.eventSections.count - 1)
                }
            } else {
                if !isNextAdded {
                    isNextAdded = true
                    self.eventSections.append(localized("event_next"))
                    subEventArray.removeAll()
                    
                    subEventArray.append(eventData)
                    self.eventArray.append(subEventArray)
                } else {
                    subEventArray.append(eventData)
                    
                    self.eventArray.remove(at: self.eventSections.count - 1)
                    self.eventArray.insert(subEventArray, at: self.eventSections.count - 1)
                }
            }
        }
    }
    
    func refreshEventData() {
        
        let query = PFQuery(className: Const.ParseClass.EventClass)
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("isOpen", equalTo:true)
        query.order(byAscending: "date")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.eventTableView.endRefreshing(at: .top)
            self.eventSections.removeAll()
            self.eventArray.removeAll()
            
            if error == nil {
                if let objects = objects {
                    
                    self.subEventArray.removeAll()
                    self.isLiveAdded = false
                    self.isNextAdded = false
                    
                    for object in objects {
                        let isDepartment = object["isDepartment"] as! Bool
                        if isDepartment {
                            let departmentArray = Config.onCheckArrayNull(object: object, key: "department")
                            let userDepartmentArray = Config.onCheckUserArrayNull(object: Config.currentUser, key: "department")
                            if self.checkContainsObjectId(userIdArray: userDepartmentArray, departmentArray: departmentArray) {
                                self.filterEventData(object: object)
                            }
                        } else {
                            self.filterEventData(object: object)
                        }
                    }
                    
                    if self.eventSections.count > 0 {
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
    
    // MARK: Action
    
    func pastEventView() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "PastEventsViewController") as! PastEventsViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func emptyTimerButtonPressed(_ sender: Any) {
        pastEventView()
    }

    @IBAction func timerButtonPressed(_ sender: Any) {
        pastEventView()
    }
    
    // MARK: UITableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.eventSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.eventSections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titleLabel: UILabel = UILabel.init(frame: CGRect(x: 26, y: 15, width: eventTableView.frame.size.width, height: 15))
        titleLabel.font = UIFont(name: "SanFranciscoText-Bold", size: 10)
        titleLabel.textColor = colorHEX("7000E3")
        titleLabel.text = self.tableView(eventTableView, titleForHeaderInSection: section)
        
        let headerView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: eventTableView.frame.size.width, height: 40))
        headerView.addSubview(titleLabel)
        headerView.backgroundColor = colorHEX("FFFFFF")
        
        return headerView
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventArray[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath as IndexPath)
        
        let readImage = cell.viewWithTag(1) as? UIImageView
        let nameLable = cell.viewWithTag(2) as? UILabel
        let timeLable = cell.viewWithTag(3) as? UILabel
      
        let eventData = self.eventArray[indexPath.section][indexPath.row]
        
        if eventData.is_read {
            readImage?.isHidden = true
        } else {
            readImage?.isHidden = false
        }
        
        nameLable?.text = eventData.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy, hh:mm a"
        let time = formatter.string(from: eventData.date)
        timeLable?.text = time.replacingOccurrences(of: ", ", with: localized("event_at"))
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        Config.eventData = self.eventArray[indexPath.section][indexPath.row]
        
        DBManager.insertEvent(email: Config.currentUser.objectId!, eventId: Config.eventData.objectId)
        Config.tabBarCtrl?.onEventDetails()
    }
}
