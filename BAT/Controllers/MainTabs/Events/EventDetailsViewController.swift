//
//  EventDetailsViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import ParseLiveQuery
import WebKit

class EventDetailsViewController: Controller, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIWebViewDelegate {
   
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var messageTableView: UITableView!
    @IBOutlet var eventVideoView: UIWebView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageView: UIView!
    @IBOutlet var messageTextView: UIView!
    
    var messageArray = [PFObject]()
    var is_anonymous = false
    
    var is_profile = false
    var is_play = false
    var eventVideoUrl = ""
    
    var is_live_query = false
    let liveQueryClient = ParseLiveQuery.Client()
    let liveMessageQueryClient = ParseLiveQuery.Client()
    var queryQuestion: PFQuery<PFObject>!
    var queryMessageQuestion: PFQuery<PFObject>!
    var subscription: Subscription<PFObject>?
    var subscriptionMessage: Subscription<PFObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        is_profile = false
        
        eventVideoView.mediaPlaybackRequiresUserAction = false
        eventVideoView.allowsInlineMediaPlayback = true
        if is_play {
            eventVideoView.stringByEvaluatingJavaScript(from: "document.querySelector('video').play();")
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopLoading()
        
        eventVideoView.stringByEvaluatingJavaScript(from: "document.querySelector('video').pause();")

        if !is_profile {            
            is_play = false
            eventVideoUrl = ""
            eventVideoView.loadHTMLString(eventVideoUrl, baseURL: nil)
            
            if is_live_query {
                self.liveQueryClient.unsubscribe(queryQuestion, handler: self.subscription!)
                self.liveMessageQueryClient.unsubscribe(queryMessageQuestion, handler: self.subscriptionMessage!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    func loadLayout() {
        
        Config.eventCtrl = self
        
        titleLabel.text = Config.eventData.title
        
        let currentDate = NSDate()
        let eventDate = Config.eventData.date
        if eventDate <= (currentDate as Date) {
            
            emptyView.isHidden = true
            mainView.isHidden = false
            
            let tapPhoto: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapPhoto(recognizer:)))
            self.profileImage.isUserInteractionEnabled = true
            self.profileImage.addGestureRecognizer(tapPhoto)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow(notification:)), name: .UIKeyboardDidShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: .UIKeyboardDidHide, object: nil)
            
            profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
            messageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            messageTextView.layer.borderWidth = 0.5
            messageTextView.layer.borderColor = colorHEX("C4C4C4").cgColor
            
            is_anonymous = false
            let photoUrl = Config.onCheckUserFileNull(object: Config.currentUser, key: "image")
            profileImage?.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(named: "ic_profile"))
            messageTextField.placeholder = localized("comment_your_name")
            
            eventVideoUrl = Config.onCheckStringNull(object: Config.eventData.eventObject, key: "streamingUrl")
            if eventVideoUrl.contains("://") && eventVideoUrl != "" {
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                } catch {
                }
                
                eventVideoView.mediaPlaybackRequiresUserAction = false
                eventVideoView.allowsInlineMediaPlayback = true
                eventVideoView.isOpaque = false
                eventVideoView.delegate = self
                let url = NSURL (string: eventVideoUrl)
                eventVideoView.loadRequest(NSURLRequest.init(url: url! as URL) as URLRequest)
                
                is_play = true
            }

            self.loadMessageData()
            
            self.showUpdateEventQuestion()
            
            self.showReceiveMessage()
            
            is_live_query = true
            
        } else {
            emptyView.isHidden = false
            mainView.isHidden = true
        }
    }
    
    // MARK: Parse Live Query
    
    func showUpdateEventQuestion() {
        queryQuestion = PFQuery(className: Const.ParseClass.EventClass)
        queryQuestion.whereKey("objectId", equalTo: Config.eventData.eventObject.objectId!)
        self.subscription = self.liveQueryClient.subscribe(queryQuestion).handle(Event.updated) { _, object in
            print("Question updated ================ ")
            Queue.main.async {
                if Config.eventData.eventObject.objectId == object.objectId {
                    let strQuestion = Config.onCheckStringNull(object: object, key: "question")
                    self.updateEventQuestion(question: strQuestion)
                }
            }
        }
    }
    
    func showReceiveMessage() {
        queryMessageQuestion = PFQuery(className: Const.ParseClass.EventMessageClass)
        queryMessageQuestion.whereKey("event", equalTo: Config.eventData.eventObject)
        queryMessageQuestion.includeKey("user")
        queryMessageQuestion.includeKey("event")
        self.subscriptionMessage = self.liveMessageQueryClient.subscribe(queryMessageQuestion).handle(Event.created) { _, object in
            print("Object created ================ ")
            Queue.main.async {
                let eventObject = object["event"] as! PFObject
                if Config.eventData.eventObject.objectId == eventObject.objectId {
                    let userObject = object["user"] as! PFUser
                    do {
                        try userObject.fetch()
                        object["user"] = userObject
                        self.messageArray.append(object)
                        self.messageTableView.reloadData()
                        let indexPath = IndexPath(row: self.messageArray.count, section: 0)
                        self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    } catch {
                    }
                }
            }
        }
    }
    
    // MARK: UIWebview Delegate
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        print("Start loading event streaming")
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        print("End loading event streaming")
        eventVideoView.stringByEvaluatingJavaScript(from: "document.querySelector('video').play();")
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Failed loading event streaming : ", error.localizedDescription)
        if is_play {
            let url = NSURL (string: eventVideoUrl)
            eventVideoView.loadRequest(NSURLRequest.init(url: url! as URL) as URLRequest)
        }
    }
    
    // MARK: Load Data
    
    func loadMessageData() {
        
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFQuery(className: Const.ParseClass.EventMessageClass)
        query.includeKey("user")
        query.includeKey("event")
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("event", equalTo:Config.eventData.eventObject)
        query.order(byAscending: "createdAt")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.stopLoading()
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.messageArray.append(object)
                    }
                    self.messageTableView.reloadData()
                }
            }
        })
    }
    
    func updateEventQuestion(question: String) {
        Config.eventData.question = question
        self.messageTableView.reloadData()
    }
    
    // MARK: UITapGestureRecognizer
    
    @objc func handleTapPhoto(recognizer : UITapGestureRecognizer) {
        
        if is_anonymous {
            is_anonymous = false
            let photoUrl = Config.onCheckUserFileNull(object: Config.currentUser, key: "image")
            profileImage?.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(named: "ic_profile"))
            messageTextField.placeholder = localized("comment_your_name")
        } else {
            is_anonymous = true
            profileImage.image = UIImage(named: "ic_profile")
            messageTextField.placeholder = localized("comment_anonymous")
        }
    }
    
    // MARK: UIKeyboard notification
    
    @objc func keyBoardDidShow(notification: NSNotification) {
        //handle appearing of keyboard here
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            var frame = self.messageTableView.frame
            frame.size.height = self.mainView.frame.size.height - keyboardHeight - 44
            self.messageTableView.frame = frame

            self.messageView.frame.origin.y = self.mainView.frame.size.height - keyboardHeight - 44
        }
    }
    
    @objc func keyBoardDidHide(notification: NSNotification) {
        //handle dismiss of keyboard here
        
        var frame = self.messageTableView.frame
        frame.size.height = self.mainView.frame.size.height - 44
        self.messageTableView.frame = frame
        
        self.messageView.frame.origin.y = self.mainView.frame.size.height - 44
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
        if messageTextField.text != "" {
            
            self.showLoading(status: localized("generic_wait"))
            
            let message = PFObject(className: Const.ParseClass.EventMessageClass)
            message["text"] = messageTextField.text!
            message["event"] = Config.eventData.eventObject
            if is_anonymous {
                message["isAnonymous"] = true
            } else {
                message["isAnonymous"] = false
            }
            message["user"] = Config.currentUser
            message["isEnabled"] = true
            message.saveInBackground(block: { (success, error) in
                self.stopLoading()
                if success {
                    self.dismissKeyboard()
                    
                    self.messageTextField.text = ""
                    self.sendButton.setImage(UIImage(named: "ic_send"), for: .normal)
                } else {
                    self.showAlert(message: localized("message_failed"))
                    return
                }
            })
        }
    }
    
    // MARK: UITableView Delegate
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath as IndexPath)
            
            let contentLable = cell.viewWithTag(1) as? UILabel
            
            let attrs1 = [NSAttributedStringKey.font : UIFont(name: "SanFranciscoText-Bold", size: 19), NSAttributedStringKey.foregroundColor : colorHEX("928F8F")]
            let attrs2 = [NSAttributedStringKey.font : UIFont(name: "SanFranciscoText-Regular", size: 19), NSAttributedStringKey.foregroundColor : colorHEX("928F8F")]
            
            let attributedString1 = NSMutableAttributedString(string:localized("event_admin"), attributes:(attrs1 as Any as! [NSAttributedStringKey : Any]))
            let attributedString2 = NSMutableAttributedString(string:Config.eventData.question, attributes:(attrs2 as Any as! [NSAttributedStringKey : Any]))
            
            attributedString1.append(attributedString2)
            contentLable?.attributedText = attributedString1
            
            return cell
        } else {
            
            let messageObject = messageArray[indexPath.row - 1]
            let createdAt = messageObject.createdAt
            let userObject = messageObject["user"] as! PFUser
            let text = Config.onCheckStringNull(object: messageObject, key: "text")
            let isAnonymous = messageObject["isAnonymous"] as! Bool
            
            userObject.fetchInBackground()
            
            if userObject.objectId == Config.currentUser.objectId {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SendCell", for: indexPath as IndexPath)
                
                let messageLable = cell.viewWithTag(1) as? UILabel
                let nametimeButton = cell.viewWithTag(2) as? UIButton
                
                messageLable?.text = text
                nametimeButton?.isEnabled = false
                let time = createdAt?.formattedTimeStamp(date: createdAt!)
                
                if isAnonymous {
                    let nametime = localized("message_you_anonymous") + " " + time!
                    nametimeButton?.setTitle(nametime, for: .normal)
                } else {
                    let nametime = localized("message_you") + " " + time!
                    nametimeButton?.setTitle(nametime, for: .normal)
                }
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveCell", for: indexPath as IndexPath)
                
                let messageLable = cell.viewWithTag(1) as? UILabel
                let nametimeButton = cell.viewWithTag(2) as? UIButton
                
                messageLable?.text = text
                
                let time = createdAt?.formattedTimeStamp(date: createdAt!)
                
                if isAnonymous {
                    let nametime = localized("message_anonymous") + " " + time!
                    nametimeButton?.setTitle(nametime, for: .normal)
                } else {
                    let name = Config.onCheckUserStringNull(object: userObject, key: "name")
                    let nametime = name + " " + time!
                    nametimeButton?.setTitle(nametime, for: .normal)
                    nametimeButton?.addTarget(self, action: #selector(self.nameButtonClicked), for: .touchUpInside)
                }
                
                return cell
            }
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    //-----------------------------
    
    @objc func nameButtonClicked(_ sender: Any) {
        let btn = sender as? UIButton
        let buttonFrameInTableView: CGRect? = btn?.convert(btn?.bounds ?? CGRect.zero, to: messageTableView)
        let indexPath: IndexPath? = messageTableView.indexPathForRow(at: buttonFrameInTableView?.origin ?? CGPoint.zero)
        
        let messageObject = messageArray[(indexPath?.row)! - 1]
        
        Config.directoryData = messageObject["user"] as! PFUser
        
        is_profile = true
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
