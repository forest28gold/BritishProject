//
//  PhotoSlideViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit

class PhotoSlideViewController: Controller {

    @IBOutlet var moreButton: UIButton!
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
        
        moreButton.isHidden = true
        
        var photoArray = [String]()
        photoArray.append(Config.onCheckFileNull(object: Config.classifiedData, key: "photo1"))
        photoArray.append(Config.onCheckFileNull(object: Config.classifiedData, key: "photo2"))
        photoArray.append(Config.onCheckFileNull(object: Config.classifiedData, key: "photo3"))
        photoArray.append(Config.onCheckFileNull(object: Config.classifiedData, key: "photo4"))
        photoArray.append(Config.onCheckFileNull(object: Config.classifiedData, key: "photo5"))
        photoArray.append(Config.onCheckFileNull(object: Config.classifiedData, key: "photo6"))
        
        for photoUrl in photoArray {
            if photoUrl != "" {
                sdWebImageSource.append(SDWebImageSource(urlString: photoUrl)!)
            }
        }
        
        slideshow.slideshowInterval = 0
        slideshow.zoomEnabled = true
        slideshow.pageControlPosition = PageControlPosition.underScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = colorHEX("FF6B0B")
        slideshow.pageControl.pageIndicatorTintColor = UIColor.white
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.currentPageChanged = { page in
            print("current page:", page)
        }
        slideshow.setImageInputs(sdWebImageSource)
    }
    
    // MARK: Action

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
