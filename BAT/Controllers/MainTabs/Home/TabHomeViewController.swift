//
//  TabHomeViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI
import PullToRefresh
import Parse

class TabHomeViewController: Controller, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var homeView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var homeTableView: UITableView!
    
    var is_load = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
        loadHomeFeedData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.testNotification()
        
        if is_load && !Config.isMedia {
            self.refreshHomeFeedData()
        }
        
        if Config.isMedia {
            Config.isMedia = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testNotification() {
        Queue.main.async {
            
//            PFCloud.callFunction(inBackground: "newPostNotification", withParameters: ["postId" : "Gr7pd04CLv" as Any, "postType" : "new_post" as Any], block: { (respond, error) in
//                if error == nil {
//                    print(respond.debugDescription)
//                } else {
//                    print(error.debugDescription)
//                }
//            })
            
//            PFCloud.callFunction(inBackground: "newMessageNotification", withParameters: ["messageId" : "VYBR9VgILA" as Any], block: { (respond, error) in
//                if error == nil {
//                    print(respond.debugDescription)
//                } else {
//                    print(error.debugDescription)
//                }
//            })
            
//            PFCloud.callFunction(inBackground: "scheduleNotification", withParameters: ["messageId" : "M77SdxT5E3" as Any], block: { (respond, error) in
//                if error == nil {
//                    print("Success ", respond.debugDescription)
//                } else {
//                    print("Error ", error.debugDescription)
//                }
//            })
            
//            PFUser.current()?.remove(forKey: "userStatus")
//            PFUser.current()?.saveInBackground()
        }
    }

    // MARK: Layout
    
    func loadLayout() {
        
        homeTableView.addPullToRefresh(PullToRefresh()) { [weak self] in
            if (self?.is_load)! {
                self?.refreshHomeFeedData()
            }
        }
        
//        homeTableView.addPullToRefresh(PullToRefresh(position: .bottom)) { [weak self] in
//            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//            DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                self?.homeTableView.reloadData()
//                self?.homeTableView.endRefreshing(at: .bottom)
//            }
//        }
    }
    
    // MARK: Load Data
    
    func loadHomeFeedData() {
        
        let currentDate = NSDate()
        
        Config.postArray.removeAll()
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFQuery(className: Const.ParseClass.PostClass)
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("expirationDate", greaterThan: currentDate)
        query.whereKey("publicationDate", lessThanOrEqualTo: currentDate)
        query.order(byDescending: "publicationDate")
//        query.includeKey("user")
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
                                self.parsePostData(object: object)
                            }
                        } else {
                            self.parsePostData(object: object)
                        }
                    }
                    
                    if Config.postArray.count > 0 {
                        self.homeTableView.reloadData()
                        self.emptyView.isHidden = true
                        self.homeView.isHidden = false
                    } else {
                        self.emptyView.isHidden = false
                        self.homeView.isHidden = true
                    }
                } else {
                    self.emptyView.isHidden = false
                    self.homeView.isHidden = true
                }
            } else {
                self.emptyView.isHidden = false
                self.homeView.isHidden = true
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
    
    func parsePostData(object: PFObject) {
        
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
        let postData = PostData.init(objectId: object.objectId!, postObject: object, type: type.lowercased(), time: time, nbLikes: nbLikes, nbComments: nbComments, nbVote: nbVote, is_like: is_like, is_voted: is_voted)
        Config.postArray.append(postData)
    }
    
    func refreshHomeFeedData() {
        
        let currentDate = NSDate()

        let query = PFQuery(className: Const.ParseClass.PostClass)
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("expirationDate", greaterThan: currentDate)
        query.whereKey("publicationDate", lessThanOrEqualTo: currentDate)
        query.order(byDescending: "publicationDate")
//        query.includeKey("user")
//        query.includeKey("department")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.homeTableView.endRefreshing(at: .top)
            Config.postArray.removeAll()
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let isDepartment = object["isDepartment"] as! Bool
                        if isDepartment {
                            let departmentArray = Config.onCheckArrayNull(object: object, key: "department")
                            let userDepartmentArray = Config.onCheckUserArrayNull(object: Config.currentUser, key: "department")
                            if self.checkContainsObjectId(userIdArray: userDepartmentArray, departmentArray: departmentArray) {
                                self.parsePostData(object: object)
                            }
                        } else {
                            self.parsePostData(object: object)
                        }
                    }
                    
                    if Config.postArray.count > 0 {
                        
                        UIView.performWithoutAnimation {
                            let range = NSMakeRange(0, self.homeTableView.numberOfSections)
                            let sections = NSIndexSet(indexesIn: range)
                            self.homeTableView.reloadSections(sections as IndexSet, with: .none)
                        }
                        
                        self.emptyView.isHidden = true
                        self.homeView.isHidden = false
                    } else {
                        self.emptyView.isHidden = false
                        self.homeView.isHidden = true
                    }
                } else {
                    self.emptyView.isHidden = false
                    self.homeView.isHidden = true
                }
            } else {
                self.emptyView.isHidden = false
                self.homeView.isHidden = true
            }
        })
    }
    
    // MARK: Settings Alert

    func homeSettings() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: localized("home_see_profile"), style: .default , handler:{ (UIAlertAction) in
            Config.isEditProfile = true
            Config.tabBarCtrl?.onSeeMyProfile()
        }))
        alert.addAction(UIAlertAction(title: localized("home_feedback"), style: .default , handler:{ (UIAlertAction) in
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([SUPPORT_EMAIL])
                mail.setSubject(localized("home_bat_feedback"))
                mail.setMessageBody("", isHTML: false)
                self.present(mail, animated: true)
            }
        }))
//        alert.addAction(UIAlertAction(title: localized("home_terms_use"), style: .default , handler:{ (UIAlertAction) in
//            Config.tabBarCtrl?.onTermsOfUse()
//        }))
//        alert.addAction(UIAlertAction(title: localized("home_privacy_policy"), style: .default , handler:{ (UIAlertAction) in
//            Config.tabBarCtrl?.onPrivacyPolicy()
//        }))
        alert.addAction(UIAlertAction(title: localized("home_logout"), style: .default , handler:{ (UIAlertAction) in
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "welcome")
            
            Queue.main.async {
                PFUser.logOut()
            }
            Config.tabBarCtrl?.onLogout()
        }))
        alert.addAction(UIAlertAction(title: localized("generic_cancel"), style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        self.present(alert, animated: true, completion:nil)
    }
    
    // MARK: MFMailCompose Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Action
    
    @IBAction func emptySettingsButtonPressed(_ sender: Any) {
        homeSettings()
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        homeSettings()
    }
    
    // MARK: UITableView Delegate
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Config.postArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postData = Config.postArray[indexPath.row]
        if postData.type == Const.PostType.post {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height / 2
            
            let postImageUrl = Config.onCheckFileNull(object: postData.postObject, key: "image")
            let postVideoUrl = Config.onCheckFileNull(object: postData.postObject, key: "video")
//            let userPhotoUrl = Config.onCheckUserFileNull(object: postData.userObject, key: "image")
//            let userName = Config.onCheckUserStringNull(object: postData.userObject, key: "name")
            let userName = Config.onCheckStringNull(object: postData.postObject, key: "postAs")
            let content = Config.onCheckStringNull(object: postData.postObject, key: "content")
            
            if postImageUrl == "" && postVideoUrl == "" {
                cell.buttonHeight.constant = 0
                cell.imageHeight.constant = 0
            } else {
                cell.buttonHeight.constant = 290
                cell.imageHeight.constant = 290
                
                if postVideoUrl != "" {
                    cell.playImage.isHidden = false
                    cell.postImage.sd_setImage(with: URL(string: postImageUrl), placeholderImage: UIImage(named: "ic_photo_placeholder"))
                } else {
                    cell.playImage.isHidden = true
                    cell.postImage.sd_setImage(with: URL(string: postImageUrl), placeholderImage: UIImage(named: "ic_img_placeholder"))
                }
            }

            cell.profileImage.isHidden = true
//            cell.profileImage.sd_setImage(with: URL(string: userPhotoUrl), placeholderImage: UIImage(named: "ic_profile"))
            
            cell.usernameLable.text = userName
            let now = Date()
            cell.timeLable.text = now.offsetTimeStamp(from: postData.time)
            cell.contentLable.text = content
            
            var strComment = localized("home_comments")
            if postData.nbComments <= 1 {
                strComment = localized("home_comment")
            }
            cell.nbLikesCommentsLable.text = String(postData.nbLikes) + "      " + String(postData.nbComments) + " " + strComment
            
            if postData.is_like {
                cell.likeButton.setImage(UIImage(named: "ic_like_selected"), for: .normal)
            } else {
                cell.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
            }
            
            cell.likeButton.addTarget(self, action: #selector(self.likeButtonClicked), for: .touchUpInside)
            cell.commentButton.addTarget(self, action: #selector(self.commentButtonClicked), for: .touchUpInside)
            cell.postImageButton.addTarget(self, action: #selector(self.postImageButtonClicked), for: .touchUpInside)
            
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath) as! PollCell
            cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height / 2
            
//            let userPhotoUrl = Config.onCheckUserFileNull(object: postData.userObject, key: "image")
//            let userName = Config.onCheckUserStringNull(object: postData.userObject, key: "name")
            let userName = Config.onCheckStringNull(object: postData.postObject, key: "postAs")
            let content = Config.onCheckStringNull(object: postData.postObject, key: "content")
            let answerArray = Config.onCheckArrayNull(object: postData.postObject, key: "answers")
            
            cell.profileImage.isHidden = true
//            cell.profileImage.sd_setImage(with: URL(string: userPhotoUrl), placeholderImage: UIImage(named: "ic_profile"))
            
            cell.usernameLable.text = userName
            let now = Date()
            cell.timeLable.text = now.offsetTimeStamp(from: postData.time)
            cell.contentLable.text = content
            
            var answerCount = 1
            
            for answer in answerArray {
                
                let answerCell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath) as! AnswerCell
                
                answerCell.answerButton.setTitle(answer, for: .normal)
                answerCell.answerButton.titleLabel?.adjustsFontSizeToFitWidth = true
                answerCell.answerButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
                answerCell.answerButton.tag = answerCount
                
                if postData.nbVote == answerCount {
                    answerCell.answerButton.backgroundColor = colorHEX("FF6B0B")
                    answerCell.answerButton.setTitleColor(UIColor.white, for: .normal)
                } else {
                    answerCell.answerButton.backgroundColor = colorHEX("EAEAEA")
                    answerCell.answerButton.setTitleColor(colorHEX("7F7D7D"), for: .normal)
                }
                
                if postData.is_voted {
                    answerCell.answerButton.isEnabled = false
                } else {
                    answerCell.answerButton.isEnabled = true
                    answerCell.answerButton.addTarget(self, action: #selector(self.voteButtonClicked), for: .touchUpInside)
                }
                
                answerCell.frame = CGRect.init(x: 0, y: CGFloat((answerCount - 1) * 60), width: cell.frame.size.width, height: answerCell.frame.size.height)
                cell.answerView.addSubview(answerCell)
                
                answerCount = answerCount + 1
            }
            
            cell.answerViewHeight.constant = CGFloat(60 * answerArray.count)
            
            var strComment = localized("home_comments")
            if postData.nbComments <= 1 {
                strComment = localized("home_comment")
            }
            cell.nbLikesCommentsLable.text = String(postData.nbLikes) + "      " + String(postData.nbComments) + " " + strComment
            
            if postData.is_like {
                cell.likeButton.setImage(UIImage(named: "ic_like_selected"), for: .normal)
            } else {
                cell.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
            }
            
            cell.likeButton.addTarget(self, action: #selector(self.likeButtonClicked), for: .touchUpInside)
            cell.commentButton.addTarget(self, action: #selector(self.commentButtonClicked), for: .touchUpInside)
            
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            
            return cell
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        Config.postData = Config.postArray[indexPath.row]
        Config.isComment = false
        
        Queue.main.async {
            let userComment = PFObject(className: Const.ParseClass.UserCommentClass)
            userComment["postId"] = Config.postData.postObject.objectId
            userComment["userId"] = Config.currentUser.objectId
            userComment["deviceId"] = Config.deviceId
            userComment.saveInBackground()
        }
        
        Config.tabBarCtrl?.onPostDetails()
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = colorHEX("F9F9F9")
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = .clear
    }
    
    //-----------------------------
    
    @objc func likeButtonClicked(_ sender: Any) {
        let btn = sender as? UIButton
        let buttonFrameInTableView: CGRect? = btn?.convert(btn?.bounds ?? CGRect.zero, to: homeTableView)
        let indexPath: IndexPath? = homeTableView.indexPathForRow(at: buttonFrameInTableView?.origin ?? CGPoint.zero)

        if Config.postArray[(indexPath?.row)!].is_like {
            Config.postArray[(indexPath?.row)!].is_like = false
            Config.postArray[(indexPath?.row)!].nbLikes = Config.postArray[(indexPath?.row)!].nbLikes - 1
            self.postDislike(postId: Config.postArray[(indexPath?.row)!].objectId, userId: Config.currentUser.objectId!)
        } else {
            Config.postArray[(indexPath?.row)!].is_like = true
            Config.postArray[(indexPath?.row)!].nbLikes = Config.postArray[(indexPath?.row)!].nbLikes + 1
            self.postLike(postId: Config.postArray[(indexPath?.row)!].objectId, userId: Config.currentUser.objectId!)
        }
        
        UIView.performWithoutAnimation({
            let loc = homeTableView.contentOffset
            homeTableView.reloadRows(at: [indexPath!], with: .none)
            homeTableView.contentOffset = loc
        })
    }
    
    @objc func commentButtonClicked(_ sender: Any) {
        let btn = sender as? UIButton
        let buttonFrameInTableView: CGRect? = btn?.convert(btn?.bounds ?? CGRect.zero, to: homeTableView)
        let indexPath: IndexPath? = homeTableView.indexPathForRow(at: buttonFrameInTableView?.origin ?? CGPoint.zero)
        
        Config.postData = Config.postArray[(indexPath?.row)!]
        Config.isComment = true
        
        Queue.main.async {
            let userComment = PFObject(className: Const.ParseClass.UserCommentClass)
            userComment["postId"] = Config.postData.postObject.objectId
            userComment["userId"] = Config.currentUser.objectId
            userComment["deviceId"] = Config.deviceId
            userComment.saveInBackground()
        }
        
        Config.tabBarCtrl?.onPostDetails()
    }
    
    @objc func postImageButtonClicked(_ sender: Any) {
        let btn = sender as? UIButton
        let buttonFrameInTableView: CGRect? = btn?.convert(btn?.bounds ?? CGRect.zero, to: homeTableView)
        let indexPath: IndexPath? = homeTableView.indexPathForRow(at: buttonFrameInTableView?.origin ?? CGPoint.zero)
        
        Config.postData = Config.postArray[(indexPath?.row)!]
        let postVideoUrl = Config.onCheckFileNull(object: Config.postData.postObject, key: "video")
        if postVideoUrl == "" {
            Config.tabBarCtrl?.onPhotoView()
        } else {
            Config.tabBarCtrl?.onVideoView()
        }
    }
    
    //-----------------------------
    
    @objc func voteButtonClicked(_ sender: Any) {
        let btn = sender as? UIButton
        let buttonFrameInTableView: CGRect? = btn?.convert(btn?.bounds ?? CGRect.zero, to: homeTableView)
        let indexPath: IndexPath? = homeTableView.indexPathForRow(at: buttonFrameInTableView?.origin ?? CGPoint.zero)
        
        let alert = UIAlertController(title: localized("home_confirm_option"), message: localized("home_alert_vote_option"), preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: localized("generic_cancel"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: localized("generic_confirm"), style: .default, handler: { action in
            Config.postArray[(indexPath?.row)!].nbVote = (btn?.tag)!
            Config.postArray[(indexPath?.row)!].is_voted = true
            self.pollVote(postId: Config.postArray[(indexPath?.row)!].objectId, userId: Config.currentUser.objectId!, voteNb: (btn?.tag)!)
            UIView.performWithoutAnimation({
                let loc = self.homeTableView.contentOffset
                self.homeTableView.reloadRows(at: [indexPath!], with: .none)
                self.homeTableView.contentOffset = loc
            })
        }))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    //--------------------------------
    
    func postLike(postId: String, userId: String) {
        Queue.main.async {
            PFCloud.callFunction(inBackground: "postLike", withParameters: ["postId" : postId, "userId" : userId], block: { (respond, error) in
                if error == nil {
                    print("Like successfully")
                } else {
                    print("Like failed")
                }
            })
        }
    }
    
    func postDislike(postId: String, userId: String) {
        Queue.main.async {
            PFCloud.callFunction(inBackground: "postDislike", withParameters: ["postId" : postId, "userId" : userId], block: { (respond, error) in
                if error == nil {
                    print("Dislike successfully")
                } else {
                    print("Dislike failed")
                }
            })
        }
    }
    
    func pollVote(postId: String, userId: String, voteNb: Int) {
        Queue.main.async {
            let strVote = String(voteNb)
            PFCloud.callFunction(inBackground: "pollVote", withParameters: ["postId" : postId, "userId" : userId, "voteNb" : strVote], block: { (respond, error) in
                if error == nil {
                    print("Vote successfully")
                } else {
                    print("Vote failed")
                }
            })
        }
    }
}
