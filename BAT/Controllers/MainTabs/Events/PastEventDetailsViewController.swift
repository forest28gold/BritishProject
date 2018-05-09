//
//  PastEventDetailsViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class PastEventDetailsViewController: Controller, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageTableView: UITableView!
    @IBOutlet var eventVideoView: UIView!
    
    var messageArray = [PFObject]()
    
    var videoItem: AVPlayerItem!
    var videoPlayer: AVPlayer!
    var avLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
        loadMessageData()
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
        titleLabel.text = Config.onCheckStringNull(object: Config.pastEventData, key: "title")
        
        let eventVideoUrl = Config.onCheckFileNull(object: Config.pastEventData, key: "streamingUrl")
        
        let videoURL = NSURL(string: eventVideoUrl)
        videoItem = AVPlayerItem(url: videoURL! as URL)
        videoPlayer = AVPlayer(playerItem: videoItem)
        avLayer = AVPlayerLayer(player: videoPlayer)
        avLayer.frame = eventVideoView.bounds
        eventVideoView.layer.addSublayer(avLayer)
        videoPlayer.play()
    }
    
    // MARK: Load Data
    
    func loadMessageData() {
        
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFQuery(className: Const.ParseClass.EventMessageClass)
        query.includeKey("user")
        query.includeKey("event")
        query.whereKey("isEnabled", equalTo:true)
        query.whereKey("event", equalTo:Config.pastEventData)
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
    
    // MARK: Action

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        
            let strQuestion = Config.onCheckStringNull(object: Config.pastEventData, key: "question")
            
            let attrs1 = [NSAttributedStringKey.font : UIFont(name: "SanFranciscoText-Bold", size: 19), NSAttributedStringKey.foregroundColor : colorHEX("928F8F")]
            let attrs2 = [NSAttributedStringKey.font : UIFont(name: "SanFranciscoText-Regular", size: 19), NSAttributedStringKey.foregroundColor : colorHEX("928F8F")]
            
            let attributedString1 = NSMutableAttributedString(string:localized("event_admin"), attributes:(attrs1 as Any as! [NSAttributedStringKey : Any]))
            let attributedString2 = NSMutableAttributedString(string:strQuestion, attributes:(attrs2 as Any as! [NSAttributedStringKey : Any]))
            
            attributedString1.append(attributedString2)
            contentLable?.attributedText = attributedString1
            
            return cell
            
        } else {
            
            let messageObject = messageArray[indexPath.row - 1]
            let createdAt = messageObject.createdAt
            let userObject = messageObject["user"] as! PFUser
            let text = Config.onCheckStringNull(object: messageObject, key: "text")
            let isAnonymous = messageObject["isAnonymous"] as! Bool
            
            if userObject.objectId == Config.currentUser.objectId {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SendCell", for: indexPath as IndexPath)
                
                let messageLable = cell.viewWithTag(1) as? UILabel
                let nametimeButton = cell.viewWithTag(2) as? UIButton
                
                messageLable?.text = text
                nametimeButton?.isEnabled = false
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, hh:mm a"
                let time = formatter.string(from: createdAt!)
                
                if isAnonymous {
                    let nametime = localized("message_you_anonymous") + " " + time
                    nametimeButton?.setTitle(nametime, for: .normal)
                } else {
                    let nametime = localized("message_you") + " " + time
                    nametimeButton?.setTitle(nametime, for: .normal)
                }
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveCell", for: indexPath as IndexPath)
                
                let messageLable = cell.viewWithTag(1) as? UILabel
                let nametimeButton = cell.viewWithTag(2) as? UIButton
                
                messageLable?.text = text
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, hh:mm a"
                let time = formatter.string(from: createdAt!)
                
                if isAnonymous {
                    let nametime = localized("message_anonymous") + " " + time
                    nametimeButton?.setTitle(nametime, for: .normal)
                } else {
                    let name = Config.onCheckUserStringNull(object: userObject, key: "name")
                    let nametime = name + " " + time
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
        
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
