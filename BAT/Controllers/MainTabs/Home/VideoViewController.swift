//
//  VideoViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import LinearProgressView

class VideoViewController: Controller {
    
    @IBOutlet weak var postVideoView: UIView!
    @IBOutlet var linearProgressView: LinearProgressView!
    @IBOutlet weak var playButton: UIButton!
    
    var videoItem: AVPlayerItem!
    var videoPlayer: AVPlayer!
    var playerController : AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer.pause()
        videoPlayer = nil
        self.stopLoading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    func loadLayout() {
        linearProgressView.animationDuration = 0.5
        
        let postVideoUrl = Config.onCheckFileNull(object: Config.postData.postObject, key: "video")
        if postVideoUrl != "" {
            
            let videoURL = NSURL(string: postVideoUrl)
            self.videoItem = AVPlayerItem(url: videoURL! as URL)
            self.videoPlayer = AVPlayer(playerItem: self.videoItem)
            self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
            self.playerController = AVPlayerViewController()
            self.playerController.player = self.videoPlayer
            self.playerController.view.frame = CGRect(x: 0, y: 0, width: self.postVideoView.frame.size.width, height: self.postVideoView.frame.size.height)
            self.playerController.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
            self.playerController.view.backgroundColor = UIColor.clear
            self.playerController.showsPlaybackControls = false
            
            self.postVideoView.addSubview(self.playerController.view)
            self.videoPlayer.play()
            
            playButton.setImage(UIImage(named: "ic_pause"), for: .normal)
            self.showLoading(status: localized("generic_wait"))
            
            videoPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { time in
                self.stopLoading()
                
                let duration = CMTimeGetSeconds(self.videoItem.duration)
                if duration > 0 {
                    self.linearProgressView.setProgress(Float((CMTimeGetSeconds(time) * 100 / duration)), animated: false)
                }
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
        }
    }
    
    // MARK: Video Play State
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        self.videoPlayer.seek(to: kCMTimeZero)
        playButton.setImage(UIImage(named: "ic_play"), for: .normal)
        self.videoPlayer.pause()
    }
    
    // MARK: Action

    @IBAction func closeButtonPressed(_ sender: Any) {
        Config.isMedia = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if (videoPlayer.rate != 0 && videoPlayer.error == nil) { // Playing
            videoPlayer.pause()
            playButton.setImage(UIImage(named: "ic_play"), for: .normal)
        } else {
            videoPlayer.play()
            playButton.setImage(UIImage(named: "ic_pause"), for: .normal)
        }
    }
}
