//
//  PhotoViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit

class PhotoViewController: Controller {

    @IBOutlet var slideshow: ImageSlideshow!
    
    var sdWebImageSource = [SDWebImageSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    func loadLayout() {
        
        let postImageUrl = Config.onCheckFileNull(object: Config.postData.postObject, key: "image")
        sdWebImageSource.append(SDWebImageSource(urlString: postImageUrl)!)
        
        slideshow.slideshowInterval = 0
        slideshow.zoomEnabled = true
        slideshow.pageControlPosition = PageControlPosition.hidden
        slideshow.pageControl.currentPageIndicatorTintColor = colorHEX("FF6B0B").withAlphaComponent(0)
        slideshow.pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.setImageInputs(sdWebImageSource)
    }
    
    // MARK: Action
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        Config.isMedia = true
        self.dismiss(animated: true, completion: nil)
    }

}
