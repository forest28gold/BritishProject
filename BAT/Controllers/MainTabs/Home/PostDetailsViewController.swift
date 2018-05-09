//
//  PostDetailsViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class PostDetailsViewController: Controller, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet var commentTableView: UITableView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var commentView: UIView!
    @IBOutlet var commentTextView: UIView!
    
    var commentArray = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
        loadCommentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Config.isLiveComment = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Config.isLiveComment = false
        
        Queue.main.async {
            let query = PFQuery(className: Const.ParseClass.UserCommentClass)
            query.whereKey("userId", equalTo:Config.currentUser.objectId!)
            query.findObjectsInBackground (block: { (objects, error) in
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Layout
    
    func loadLayout() {
        
        Config.commentCtrl = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: .UIKeyboardDidHide, object: nil)
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        commentTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.borderColor = colorHEX("C4C4C4").cgColor
        
        let photoUrl = Config.onCheckUserFileNull(object: Config.currentUser, key: "image")
        profileImage?.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(named: "ic_profile"))
        
        if Config.isComment {
            commentTextField.becomeFirstResponder()
        }
    }
    
    // MARK: Load Data
    
    func loadCommentData() {
        
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFQuery(className: Const.ParseClass.PostCommentClass)
        query.includeKey("user")
        query.includeKey("post")
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("status", equalTo:Const.CommentStatus.approved)
        query.whereKey("post", equalTo:Config.postData.postObject)
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.stopLoading()
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.commentArray.append(object)
                    }
                    self.commentTableView.reloadData()
                }
            }
        })
    }
    
    func refreshCommentData() {
        
        Queue.main.async {
            let query = PFQuery(className: Const.ParseClass.PostCommentClass)
            query.includeKey("user")
            query.includeKey("post")
            query.whereKey("isEnabled", equalTo:true)
            query.whereKey("status", equalTo:Const.CommentStatus.approved)
            query.whereKey("post", equalTo:Config.postData.postObject)
            query.limit = QUERY_LIMIT
            query.findObjectsInBackground (block: { (objects, error) in
                self.commentArray.removeAll()
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            self.commentArray.append(object)
                        }
                        if objects.count > 0 {
                            let postObject = objects[0]["post"] as! PFObject
                            let nbComments = Config.onCheckNumberNull(object: postObject, key: "nbComments")
                            let nbLikes = Config.onCheckNumberNull(object: postObject, key: "nbLikes")
                            Config.postData.nbComments = nbComments
                            Config.postData.nbLikes = nbLikes
                        }
//                        let indexPath = IndexPath(row: self.commentArray.count, section: 0)
//                        self.commentTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        self.commentTableView.reloadData()
                    }
                }
            })
        }
    }
    
    // MARK: UIKeyboard notification
    
    @objc func keyBoardDidShow(notification: NSNotification) {
        //handle appearing of keyboard here
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
        
        var frame = self.commentTableView.frame
        frame.size.height = self.mainView.frame.size.height - keyboardHeight! - 44
        self.commentTableView.frame = frame
        
        self.commentView.frame.origin.y = self.mainView.frame.size.height - keyboardHeight! - 44
    }
    
    @objc func keyBoardDidHide(notification: NSNotification) {
        //handle dismiss of keyboard here
        
        var frame = self.commentTableView.frame
        frame.size.height = self.mainView.frame.size.height - 44
        self.commentTableView.frame = frame

        self.commentView.frame.origin.y = self.mainView.frame.size.height - 44
    }
    
    // MARK: UITextField Delegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            sendButton.setImage(UIImage(named: "ic_send"), for: .normal)
        } else {
            sendButton.setImage(UIImage(named: "ic_sent"), for: .normal)
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: Action

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if commentTextField.text != "" {
            
            self.showLoading(status: localized("generic_wait"))
            
            let comment = PFObject(className: Const.ParseClass.PostCommentClass)
            comment["text"] = commentTextField.text!
            comment["status"] = Const.CommentStatus.pending
            comment["post"] = Config.postData.postObject
            comment["user"] = Config.currentUser
            comment["lang"] = Config.currentLocale
            comment["isEnabled"] = true
            comment.saveInBackground(block: { (success, error) in
                if success {
                    self.dismissKeyboard()
                    
                    self.commentTextField.text = ""
                    self.sendButton.setImage(UIImage(named: "ic_send"), for: .normal)
                    
                    self.showSuccess(success: localized("post_comment_submitted"))
                } else {
                    self.showAlert(message: localized("post_comment_failed"))
                    return
                }
            })
        }
    }
    
    // MARK: UITableView Delegate
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            if Config.postData.type == Const.PostType.post {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
                cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height / 2
                
                let postImageUrl = Config.onCheckFileNull(object: Config.postData.postObject, key: "image")
                let postVideoUrl = Config.onCheckFileNull(object: Config.postData.postObject, key: "video")
//                let userPhotoUrl = Config.onCheckUserFileNull(object: Config.postData.userObject, key: "image")
//                let userName = Config.onCheckUserStringNull(object: Config.postData.userObject, key: "name")
                let userName = Config.onCheckStringNull(object: Config.postData.postObject, key: "postAs")
                let content = Config.onCheckStringNull(object: Config.postData.postObject, key: "content")
                
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
//                cell.profileImage.sd_setImage(with: URL(string: userPhotoUrl), placeholderImage: UIImage(named: "ic_profile"))
                
                cell.usernameLable.text = userName
                let now = Date()
                cell.timeLable.text = now.offsetTimeStamp(from: Config.postData.time)
                cell.contentLable.text = content
                
                var strComment = localized("home_comments")
                if Config.postData.nbComments <= 1 {
                    strComment = localized("home_comment")
                }
                cell.nbLikesCommentsLable.text = String(Config.postData.nbLikes) + "      " + String(Config.postData.nbComments) + " " + strComment
                
                if Config.postData.is_like {
                    cell.likeButton.setImage(UIImage(named: "ic_like_selected"), for: .normal)
                } else {
                    cell.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
                }
                
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonClicked), for: .touchUpInside)
                cell.commentButton.isHidden = true
                cell.postImageButton.addTarget(self, action: #selector(self.postImageButtonClicked), for: .touchUpInside)
                
                cell.selectionStyle = .none
                cell.layoutIfNeeded()
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath) as! PollCell
                cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height / 2

//                let userPhotoUrl = Config.onCheckUserFileNull(object: Config.postData.userObject, key: "image")
//                let userName = Config.onCheckUserStringNull(object: Config.postData.userObject, key: "name")
                let userName = Config.onCheckStringNull(object: Config.postData.postObject, key: "postAs")
                let content = Config.onCheckStringNull(object: Config.postData.postObject, key: "content")
                let answerArray = Config.onCheckArrayNull(object: Config.postData.postObject, key: "answers")
                
                cell.profileImage.isHidden = true
//                cell.profileImage.sd_setImage(with: URL(string: userPhotoUrl), placeholderImage: UIImage(named: "ic_profile"))
                
                cell.usernameLable.text = userName
                let now = Date()
                cell.timeLable.text = now.offsetTimeStamp(from: Config.postData.time)
                cell.contentLable.text = content
                
                var answerCount = 1
                
                for answer in answerArray {
                    
                    let answerCell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath) as! AnswerCell
                    
                    answerCell.answerButton.setTitle(answer, for: .normal)
                    answerCell.answerButton.titleLabel?.adjustsFontSizeToFitWidth = true
                    answerCell.answerButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
                    answerCell.answerButton.tag = answerCount
                    
                    if Config.postData.nbVote == answerCount {
                        answerCell.answerButton.backgroundColor = colorHEX("FF6B0B")
                        answerCell.answerButton.setTitleColor(UIColor.white, for: .normal)
                    } else {
                        answerCell.answerButton.backgroundColor = colorHEX("EAEAEA")
                        answerCell.answerButton.setTitleColor(colorHEX("7F7D7D"), for: .normal)
                    }
                    
                    if Config.postData.is_voted {
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
                if Config.postData.nbComments <= 1 {
                    strComment = localized("home_comment")
                }
                cell.nbLikesCommentsLable.text = String(Config.postData.nbLikes) + "      " + String(Config.postData.nbComments) + " " + strComment
                
                if Config.postData.is_like {
                    cell.likeButton.setImage(UIImage(named: "ic_like_selected"), for: .normal)
                } else {
                    cell.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
                }
                
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonClicked), for: .touchUpInside)
                cell.commentButton.isHidden = true
                
                cell.selectionStyle = .none
                cell.layoutIfNeeded()
                
                return cell
            }
            
        } else {
            
            let commentData = commentArray[indexPath.row - 1]
            let userObject = commentData["user"] as! PFUser
            let userPhotoUrl = Config.onCheckUserFileNull(object: userObject, key: "image")
            let userName = Config.onCheckUserStringNull(object: userObject, key: "name")
            let text = Config.onCheckStringNull(object: commentData, key: "text")
            let time = commentData.createdAt
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath as IndexPath)
            
            let profileImage = cell.viewWithTag(1) as? UIImageView
            let contentLable = cell.viewWithTag(2) as? UILabel
            let nametimeLable = cell.viewWithTag(3) as? UILabel
            
            profileImage?.layer.cornerRadius = (profileImage?.frame.size.height)! / 2
            
            profileImage?.sd_setImage(with: URL(string: userPhotoUrl), placeholderImage: UIImage(named: "ic_profile"))
            
            contentLable?.text = text
            nametimeLable?.text = userName + " " + localized("post_at") + " " + (time?.formattedTimeStamp(date: time!))!
            
            return cell
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    //-----------------------------
    
    @objc func likeButtonClicked(_ sender: Any) {

        if Config.postData.is_like {
            Config.postData.is_like = false
            Config.postData.nbLikes = Config.postData.nbLikes - 1
            self.postDislike(postId: Config.postData.objectId, userId: Config.currentUser.objectId!)
        } else {
            Config.postData.is_like = true
            Config.postData.nbLikes = Config.postData.nbLikes + 1
            self.postLike(postId: Config.postData.objectId, userId: Config.currentUser.objectId!)
        }
        
        self.commentTableView.reloadData()
    }
    
    @objc func postImageButtonClicked(_ sender: Any) {
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
        
        let alert = UIAlertController(title: localized("home_confirm_option"), message: localized("home_alert_vote_option"), preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: localized("generic_cancel"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: localized("generic_confirm"), style: .default, handler: { action in
            Config.postData.nbVote = (btn?.tag)!
            Config.postData.is_voted = true
            self.pollVote(postId: Config.postData.objectId, userId: Config.currentUser.objectId!, voteNb: (btn?.tag)!)
            self.commentTableView.reloadData()
        }))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    //-----------------------------
    
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
