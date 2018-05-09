//
//  ClassifiedDetailsViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse

class ClassifiedDetailsViewController: Controller {
    
    @IBOutlet weak var btnLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var btnRightMargin: NSLayoutConstraint!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var classifiedNameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var contactButton: UIButton!
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
        
        iPhoneX {
            self.btnLeftMargin.constant += CGFloat(BUTTON_MARGIN)
            self.btnRightMargin.constant += CGFloat(BUTTON_MARGIN)
            self.contactButton.layer.cornerRadius = CGFloat(BUTTON_RADIUS)
            self.view.layoutIfNeeded()
        }
        
        let postUser = Config.classifiedData["user"] as! PFUser
        
        if Config.currentUser.objectId == postUser.objectId {
            moreButton.isHidden = false
            contactButton.isHidden = true
        } else {
            moreButton.isHidden = true
            contactButton.isHidden = false
        }
        
        let username = Config.onCheckUserStringNull(object: postUser, key: "name")
        usernameLabel.text = username
        classifiedNameLabel.text = Config.onCheckStringNull(object: Config.classifiedData, key: "name")
        priceLabel.text = Config.onCheckStringNull(object: Config.classifiedData, key: "price")
        descriptionLabel.text = Config.onCheckStringNull(object: Config.classifiedData, key: "desc")
        
        var firstName = username
        if username.contains(" ") {
            firstName = username.components(separatedBy: " ")[0]
        }
        contactButton.setTitle(localized("classified_contact") + " " + firstName, for: .normal)
        
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
        slideshow.pageControlPosition = PageControlPosition.insideScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = colorHEX("FF6B0B")
        slideshow.pageControl.pageIndicatorTintColor = UIColor.white
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.currentPageChanged = { page in
            print("current page:", page)
        }
        slideshow.setImageInputs(sdWebImageSource)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ClassifiedDetailsViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
    }
    
    // MARK: Action
    
    @objc func didTap() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSlideViewController") as! PhotoSlideViewController
        self.navigationController?.present(nextViewController, animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: localized("edit_classified"), style: .default , handler:{ (UIAlertAction) in
            Config.isEditClassified = true
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditClassifiedViewController") as! EditClassifiedViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: localized("delete_classified"), style: .destructive , handler:{ (UIAlertAction) in
            Queue.main.async {
                Config.classifiedData.deleteInBackground()
            }
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: localized("generic_cancel"), style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        self.present(alert, animated: true, completion:nil)
    }
    
    @IBAction func contactButtonPressed(_ sender: Any) {
        
        Config.directoryData = Config.classifiedData["user"] as! PFUser
        
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
