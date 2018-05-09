//
//  PreviewClassifiedViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import Parse

class PreviewClassifiedViewController: Controller {
   
    @IBOutlet weak var btnLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var btnRightMargin: NSLayoutConstraint!
    
    @IBOutlet var postButton: UIButton!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var classifiedNameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var slideshow: ImageSlideshow!
    
    var localSource = [InputSource]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
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
        
        iPhoneX {
            self.btnLeftMargin.constant += CGFloat(BUTTON_MARGIN)
            self.btnRightMargin.constant += CGFloat(BUTTON_MARGIN)
            self.postButton.layer.cornerRadius = CGFloat(BUTTON_RADIUS)
            self.view.layoutIfNeeded()
        }
        
        usernameLabel.text = Config.onCheckUserStringNull(object: Config.currentUser, key: "name")
        classifiedNameLabel.text = Config.classifiedPreviewData.name
        priceLabel.text = Config.classifiedPreviewData.price
        descriptionLabel.text = Config.classifiedPreviewData.desc
        
        for photoData in Config.photoArray {
            if photoData.photo != UIImage(named: "ic_photo_placeholder") {
                localSource.append(ImageSource(image: photoData.photo))
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
        slideshow.setImageInputs(localSource)
    }
    
    // MARK: Action

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        
        if Config.isEditClassified {
            updateClassifiedData()
        } else {
            saveClassifiedData()
        }
    }
    
    func updateClassifiedData() {
        
        self.showLoading(status: localized("generic_wait"))
        
        var updateCount = 0
        
        for photoData in Config.photoArray {
            if photoData.isEdit {
                if !photoData.isRemove && photoData.photo != UIImage(named: "ic_photo_placeholder") {
                    updateCount = updateCount + 1
                }
            }
        }
        
        if updateCount > 0 {
            
            var updatePhotoCount = 1
            let classifieds = PFObject(className: Const.ParseClass.ClassifiedsClass)
            classifieds.objectId = Config.classifiedData.objectId
            
            var photoCount = 0
            for photoData in Config.photoArray {
                photoCount = photoCount + 1
                if photoData.isEdit {
                    if !photoData.isRemove && photoData.photo != UIImage(named: "ic_photo_placeholder") {
                        let fileName = Config.randomNumber(length: 8) + ".png"
                        let imageData = UIImagePNGRepresentation(photoData.photo)
                        let imageFile = PFFile(name:fileName, data:imageData!)
                        imageFile?.saveInBackground(block: { (success, error) in
                            if success {
                                classifieds["photo" + String(photoCount)] = imageFile
                                
                                if updatePhotoCount == updateCount {
                                    
                                    classifieds["isEnabled"] = true
                                    classifieds["user"] = Config.currentUser
                                    classifieds["name"] = Config.classifiedPreviewData.name
                                    classifieds["price"] = Config.classifiedPreviewData.price
                                    classifieds["desc"] = Config.classifiedPreviewData.desc
                                    if Config.classifiedPreviewData.price.contains(localized("classified_hour")) {
                                        classifieds["type"] = "hour"
                                    } else {
                                        classifieds["type"] = "one_time"
                                    }
                                    classifieds["lang"] = Config.currentLocale
                                    classifieds.saveInBackground(block: { (success, error) in
                                        self.stopLoading()
                                        if success {
                                            self.performSegue(withIdentifier: UNWIND_PREVIEW_CLASSIFIED, sender: self)
                                        } else {
                                            self.showAlert(message: localized("classified_save_failed"))
                                            return
                                        }
                                    })
                                } else {
                                    updatePhotoCount = updatePhotoCount + 1
                                }
                            } else {
                                updatePhotoCount = updatePhotoCount + 1
                            }
                        })
                    }
                }
            }
        } else {
            
            let classifieds = PFObject(className: Const.ParseClass.ClassifiedsClass)
            classifieds.objectId = Config.classifiedData.objectId
            
            var photoCount = 0
            for photoData in Config.photoArray {
                photoCount = photoCount + 1
                if photoData.isEdit && photoData.isRemove {
                    classifieds.remove(forKey: "photo" + String(photoCount))
                }
            }
            
            classifieds["isEnabled"] = true
            classifieds["name"] = Config.classifiedPreviewData.name
            classifieds["price"] = Config.classifiedPreviewData.price
            classifieds["desc"] = Config.classifiedPreviewData.desc
            if Config.classifiedPreviewData.price.contains(localized("classified_hour")) {
                classifieds["type"] = "hour"
            } else {
                classifieds["type"] = "one_time"
            }
            classifieds["lang"] = Config.currentLocale
            classifieds.saveInBackground(block: { (success, error) in
                self.stopLoading()
                if success {
                    self.performSegue(withIdentifier: UNWIND_PREVIEW_CLASSIFIED, sender: self)
                } else {
                    self.showAlert(message: localized("classified_save_failed"))
                    return
                }
            })
        }
    }
    
    func saveClassifiedData() {
        
        self.showLoading(status: localized("generic_wait"))

        var imageArray = [UIImage]()
        for photoData in Config.photoArray {
            if photoData.photo != UIImage(named: "ic_photo_placeholder") {
                imageArray.append(photoData.photo)
            }
        }
        
        var photoCount = 1
        let classifieds = PFObject(className: Const.ParseClass.ClassifiedsClass)
        
        for photoData in imageArray {
            let fileName = Config.randomNumber(length: 8) + ".png"
            let imageData = UIImagePNGRepresentation(photoData)
            let imageFile = PFFile(name:fileName, data:imageData!)
            imageFile?.saveInBackground(block: { (success, error) in
                if error == nil {
                    classifieds["photo" + String(photoCount)] = imageFile
                    
                    if photoCount == imageArray.count {
                        
                        classifieds["isEnabled"] = true
                        classifieds["user"] = Config.currentUser
                        classifieds["name"] = Config.classifiedPreviewData.name
                        classifieds["price"] = Config.classifiedPreviewData.price
                        classifieds["desc"] = Config.classifiedPreviewData.desc
                        if Config.classifiedPreviewData.price.contains(localized("classified_hour")) {
                            classifieds["type"] = "hour"
                        } else {
                            classifieds["type"] = "one_time"
                        }
                        classifieds["lang"] = Config.currentLocale
                        classifieds.saveInBackground(block: { (success, error) in
                            self.stopLoading()
                            if success {
                                self.performSegue(withIdentifier: UNWIND_PREVIEW_CLASSIFIED, sender: self)
                            } else {
                                self.showAlert(message: localized("classified_save_failed"))
                                return
                            }
                        })
                    } else {
                        photoCount = photoCount + 1
                    }
                    print("photo count ", photoCount)
                } else {
                    photoCount = photoCount + 1
                    print("photo error ", error.debugDescription)
                }
            })
        }
    }
    
    func photoFileDelete(photoFileUrl: String) {
        Queue.main.async {
            PFCloud.callFunction(inBackground: "photoFileDelete", withParameters: ["photoFileUrl" : photoFileUrl as Any], block: { (respond, error) in
                if error == nil {
                    print("Delete file successfully")
                } else {
                    print("Delete file is failed")
                }
            })
        }
    }
}
