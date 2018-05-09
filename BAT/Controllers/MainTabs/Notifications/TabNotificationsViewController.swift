//
//  TabNotificationsViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import PullToRefresh
import Parse

class TabNotificationsViewController: Controller, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var notificationView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var notificationTableView: UITableView!
    
    var is_load = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
        loadNotificationData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if is_load {
            self.refreshNotificationData()
        }
        
        initbadgeCount()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Config.tabBarCtrl?.tabBar.items![2].image = UIImage(named: "ic_tab_notification")
        Config.tabBarCtrl?.tabBar.items![2].selectedImage = UIImage(named: "ic_tab_notification_selected")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    func loadLayout() {
        notificationTableView.addPullToRefresh(PullToRefresh()) { [weak self] in
            if (self?.is_load)! {
                self?.refreshNotificationData()
            }
        }
    }
    
    // MARK: Load Data
    
    func loadNotificationData() {

        Config.notificationArray.removeAll()
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFQuery(className: Const.ParseClass.NotificationClass)
        query.whereKey("receiver", equalTo:Config.currentUser)
        query.includeKey("receiver")
        query.includeKey("post")
        query.includeKey("event")
        query.includeKey("message")
        query.order(byDescending: "createdAt")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.stopLoading()
            self.is_load = true
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        Config.notificationArray.append(object)
                    }
                    
                    if Config.notificationArray.count > 0 {
                        self.notificationTableView.reloadData()
                        self.emptyView.isHidden = true
                        self.notificationView.isHidden = false
                    } else {
                        self.emptyView.isHidden = false
                        self.notificationView.isHidden = true
                    }
                } else {
                    self.emptyView.isHidden = false
                    self.notificationView.isHidden = true
                }
            } else {
                self.emptyView.isHidden = false
                self.notificationView.isHidden = true
            }
        })
    }
    
    func refreshNotificationData() {
        
        let query = PFQuery(className: Const.ParseClass.NotificationClass)
        query.whereKey("receiver", equalTo:Config.currentUser)
        query.includeKey("receiver")
        query.includeKey("post")
        query.includeKey("event")
        query.includeKey("message")
        query.order(byDescending: "createdAt")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.notificationTableView.endRefreshing(at: .top)
            Config.notificationArray.removeAll()
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        Config.notificationArray.append(object)
                    }
                    
                    if Config.notificationArray.count > 0 {
                        
                        UIView.performWithoutAnimation {
                            let range = NSMakeRange(0, self.notificationTableView.numberOfSections)
                            let sections = NSIndexSet(indexesIn: range)
                            self.notificationTableView.reloadSections(sections as IndexSet, with: .none)
                        }
                        
                        self.emptyView.isHidden = true
                        self.notificationView.isHidden = false
                    } else {
                        self.emptyView.isHidden = false
                        self.notificationView.isHidden = true
                    }
                } else {
                    self.emptyView.isHidden = false
                    self.notificationView.isHidden = true
                }                
            } else {
                self.emptyView.isHidden = false
                self.notificationView.isHidden = true
            }
        })
    }
    
    func initbadgeCount() {
        
        Queue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            let installation = PFInstallation.current()
            installation?.badge = 0
            installation?.saveInBackground()
        }
    }

    // MARK: UITableView Delegate
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Config.notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath as IndexPath)
        
        let readImage = cell.viewWithTag(1) as? UIImageView
        let contentLable = cell.viewWithTag(2) as? UILabel
        
        let notificationObject = Config.notificationArray[indexPath.row]
        let isViewed = notificationObject["isViewed"] as! Bool
        let createdAt = notificationObject.createdAt
        let type = Config.onCheckStringNull(object: notificationObject, key: "type")
        
        if !isViewed {
            readImage?.isHidden = false
        } else {
            readImage?.isHidden = true
        }
        
        let now = Date()
        let strNotiTime = now.offsetTimeStamp(from: createdAt!)
        
        var strNotiType = "", strNotiStatus = "", strNotiContent = ""
        
        if type == Const.NotiType.CommentPostDeclined {
            strNotiType = localized("notification_comment_post") + " "
            strNotiStatus = localized("notification_declined") + "   "
            let postObject = notificationObject["post"] as! PFObject
            strNotiContent = self.contentSubstring(object: postObject, key: "content")
        } else if type == Const.NotiType.NewPost {
            let postObject = notificationObject["post"] as! PFObject
            strNotiType = Config.onCheckStringNull(object: postObject, key: "postAs") + " " + localized("notification_create_post") + " "
            strNotiStatus = "   "
            strNotiContent = self.contentSubstring(object: postObject, key: "content")
        } else if type == Const.NotiType.CommentPollDeclined {
            strNotiType = localized("notification_comment_poll") + " "
            strNotiStatus = localized("notification_declined") + "   "
            let postObject = notificationObject["post"] as! PFObject
            strNotiContent = self.contentSubstring(object: postObject, key: "content")
        } else if type == Const.NotiType.NewPoll {
            let postObject = notificationObject["post"] as! PFObject
            strNotiType = Config.onCheckStringNull(object: postObject, key: "postAs") + " " + localized("notification_create_poll") + " "
            strNotiStatus = "   "
            strNotiContent = self.contentSubstring(object: postObject, key: "content")
        } else if type == Const.NotiType.EventScheduled {
            strNotiType = localized("notification_event") + " "
            strNotiStatus = localized("notification_scheduled") + "   "
            let eventObject = notificationObject["event"] as! PFObject
            strNotiContent = self.contentSubstring(object: eventObject, key: "title")
        } else if type == Const.NotiType.EventLive {
            strNotiType = localized("notification_event") + " "
            strNotiStatus = localized("notification_live") + "   "
            let eventObject = notificationObject["event"] as! PFObject
            strNotiContent = self.contentSubstring(object: eventObject, key: "title")
        } else if type == Const.NotiType.NewMessage {
            strNotiType = localized("notification_message") + " "
            strNotiStatus = "   "
            let messageObject = notificationObject["message"] as! PFObject
            strNotiContent = self.contentSubstring(object: messageObject, key: "content")
        }
        
        let attrs1 = [NSAttributedStringKey.font : UIFont(name: "SanFranciscoText-Regular", size: 19), NSAttributedStringKey.foregroundColor : colorHEX("928F8F")]
        let attrs2 = [NSAttributedStringKey.font : UIFont(name: "SanFranciscoText-Bold", size: 19), NSAttributedStringKey.foregroundColor : colorHEX("928F8F")]
        let attrs3 = [NSAttributedStringKey.font : UIFont(name: "SanFranciscoText-Regular", size: 19), NSAttributedStringKey.foregroundColor : colorHEX("928F8F")]
        let attrs4 = [NSAttributedStringKey.font : UIFont(name: "SanFranciscoText-Regular", size: 11), NSAttributedStringKey.foregroundColor : colorHEX("FF6B0B")]
        
        let attributedString1 = NSMutableAttributedString(string:strNotiType, attributes:(attrs1 as Any as! [NSAttributedStringKey : Any]))
        let attributedString2 = NSMutableAttributedString(string:strNotiContent, attributes:(attrs2 as Any as! [NSAttributedStringKey : Any]))
        let attributedString3 = NSMutableAttributedString(string:strNotiStatus, attributes:(attrs3 as Any as! [NSAttributedStringKey : Any]))
        let attributedString4 = NSMutableAttributedString(string:strNotiTime, attributes:(attrs4 as Any as! [NSAttributedStringKey : Any]))
        
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        attributedString1.append(attributedString4)
        
        contentLable?.attributedText = attributedString1
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let notificationObject = Config.notificationArray[indexPath.row]
        
        Queue.main.async {
            let notification = PFObject(className: Const.ParseClass.NotificationClass)
            notification.objectId = notificationObject.objectId!
            notification["isViewed"] = true
            notification.saveInBackground()
        }
        
        let currentDate = NSDate()
        
        let type = Config.onCheckStringNull(object: notificationObject, key: "type")
        if type == Const.NotiType.CommentPostDeclined {
            let postObject = notificationObject["post"] as! PFObject
            let isEnabled = postObject["isEnabled"] as! Bool
            if isEnabled {
                let expireDate = postObject["expirationDate"] as! Date
                if expireDate <= (currentDate as Date) {
                    self.showAlert(message: localized("post_removed"))
                    return
                } else {
                    Config.postData = self.parsePostData(object: postObject)
                    Config.tabBarCtrl?.onPostDetails()
                }
            } else {
                self.showAlert(message: localized("post_removed"))
                return
            }
        } else if type == Const.NotiType.NewPost {
            let postObject = notificationObject["post"] as! PFObject
            let isEnabled = postObject["isEnabled"] as! Bool
            if isEnabled {
                let expireDate = postObject["expirationDate"] as! Date
                if expireDate <= (currentDate as Date) {
                    self.showAlert(message: localized("post_removed"))
                    return
                } else {
                    Config.postData = self.parsePostData(object: postObject)
                    Config.tabBarCtrl?.onPostDetails()
                }
            } else {
                self.showAlert(message: localized("post_removed"))
                return
            }
        } else if type == Const.NotiType.CommentPollDeclined {
            let postObject = notificationObject["post"] as! PFObject
            let isEnabled = postObject["isEnabled"] as! Bool
            if isEnabled {
                let expireDate = postObject["expirationDate"] as! Date
                if expireDate <= (currentDate as Date) {
                    self.showAlert(message: localized("poll_removed"))
                    return
                } else {
                    Config.postData = self.parsePostData(object: postObject)
                    Config.tabBarCtrl?.onPostDetails()
                }
            } else {
                self.showAlert(message: localized("poll_removed"))
                return
            }
        } else if type == Const.NotiType.NewPoll {
            let postObject = notificationObject["post"] as! PFObject
            let isEnabled = postObject["isEnabled"] as! Bool
            if isEnabled {
                let expireDate = postObject["expirationDate"] as! Date
                if expireDate <= (currentDate as Date) {
                    self.showAlert(message: localized("poll_removed"))
                    return
                } else {
                    Config.postData = self.parsePostData(object: postObject)
                    Config.tabBarCtrl?.onPostDetails()
                }
            } else {
                self.showAlert(message: localized("poll_removed"))
                return
            }
        } else if type == Const.NotiType.EventScheduled {
            let eventObject = notificationObject["event"] as! PFObject
            let isEnabled = eventObject["isEnabled"] as! Bool
            if isEnabled {
                let isOpen = eventObject["isOpen"] as! Bool
                if (isOpen) {
                    Config.eventData = self.parseEventData(object: eventObject)
                    Config.tabBarCtrl?.onEventDetails()
                } else {
                    Config.pastEventData = eventObject
                    Config.tabBarCtrl?.onPastEventDetails()
                }
            } else {
                self.showAlert(message: localized("event_removed"))
                return
            }
        } else if type == Const.NotiType.EventLive {
            let eventObject = notificationObject["event"] as! PFObject
            let isEnabled = eventObject["isEnabled"] as! Bool
            if isEnabled {
                let isOpen = eventObject["isOpen"] as! Bool
                if (isOpen) {
                    Config.eventData = self.parseEventData(object: eventObject)
                    Config.tabBarCtrl?.onEventDetails()
                } else {
                    Config.pastEventData = eventObject
                    Config.tabBarCtrl?.onPastEventDetails()
                }
            } else {
                self.showAlert(message: localized("event_removed"))
                return
            }
        } else if type == Const.NotiType.NewMessage {
            Config.messageData = notificationObject["message"] as! PFObject
            let isEnabled = Config.messageData["isEnabled"] as! Bool
            if isEnabled {
                Config.tabBarCtrl?.onMessageDetails()
            } else {
                self.showAlert(message: localized("message_removed"))
                return
            }
        }
    }
    
    func contentSubstring(object: PFObject, key: String) -> String {
        let strNotiContent = Config.onCheckStringNull(object: object, key: key)
        if strNotiContent == "" {
            return "  "
        } else if strNotiContent.length >= NOTI_LIMIT {
            return strNotiContent.prefix(NOTI_LIMIT) + " ...  "
        } else {
            return strNotiContent + "  "
        }
    }
    
    func parsePostData(object: PFObject) -> PostData {
        let type = Config.onCheckStringNull(object: object, key: "type")
        let time = object["publicationDate"] as! Date
//        let userObject = object["user"] as! PFUser
        let nbLikes = Config.onCheckNumberNull(object: object, key: "nbLikes")
        let nbComments = Config.onCheckNumberNull(object: object, key: "nbComments")
        let likes = Config.onCheckArrayNull(object: object, key: "likes")
        let votes = Config.onCheckArrayNull(object: object, key: "votes")
        var is_like = false, is_voted = false, nbVote = 0
        if likes.contains(Config.currentUser.objectId!) {
            is_like = true
        }
        for vote in votes {
            let userId = vote.components(separatedBy: ":")[0]
            let voteNb = vote.components(separatedBy: ":")[1]
            if userId == Config.currentUser.objectId {
                is_voted = true
                nbVote = Int(voteNb)!
                break
            }
        }
        return PostData.init(objectId: object.objectId!, postObject: object, type: type, time: time, nbLikes: nbLikes, nbComments: nbComments, nbVote: nbVote, is_like: is_like, is_voted: is_voted)
    }
    
    func parseEventData(object: PFObject) -> EventData {
        let title = Config.onCheckStringNull(object: object, key: "title")
        let date = object["date"] as! Date
        let question = Config.onCheckStringNull(object: object, key: "question")
        let streamingUrl = Config.onCheckStringNull(object: object, key: "streamingUrl")
        let is_read = true
        
        return EventData.init(objectId: object.objectId!, eventObject: object, title: title, date: date, question: question, streamingUrl: streamingUrl, is_read: is_read)
    }
}
