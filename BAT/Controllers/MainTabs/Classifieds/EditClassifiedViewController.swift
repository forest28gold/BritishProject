//
//  EditClassifiedViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import Parse

class EditClassifiedViewController: Controller, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var btnLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var btnRightMargin: NSLayoutConstraint!
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var priceTextField: CurrencyTextfieldForrmatter!
    @IBOutlet var switchButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var pickerController = UIImagePickerController()
    var isSwitchOn = false
    var selectedIndex: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Config.strDescription == "" {
            descriptionLabel.text = localized("edit_description")
            descriptionLabel.textColor = colorHEX("C4C4C4")
        } else {
            descriptionLabel.text = Config.strDescription
            descriptionLabel.textColor = colorHEX("928F8F")
        }
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
            self.nextButton.layer.cornerRadius = CGFloat(BUTTON_RADIUS)
            self.view.layoutIfNeeded()
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
        
        priceTextField.delegate = self
        
        Config.photoArray.removeAll()
        
        if Config.isEditClassified {
            cancelButton.isHidden = false
            backButton.isHidden = true
            titleLabel.text = localized("edit_classified")
            
            let price = Config.onCheckStringNull(object: Config.classifiedData, key: "price")
            Config.strDescription = Config.onCheckStringNull(object: Config.classifiedData, key: "desc")
            
            nameTextField.text = Config.onCheckStringNull(object: Config.classifiedData, key: "name")
            descriptionLabel.text = Config.strDescription
            if price.contains(localized("classified_hour")) {
                priceTextField.text = price.replacingOccurrences(of: localized("classified_hour"), with: "")
                isSwitchOn = true
            } else {
                priceTextField.text = price
                isSwitchOn = false
            }
            
            for i in 0..<6 {
                let photoUrl = Config.onCheckFileNull(object: Config.classifiedData, key: "photo" + String(i + 1))
                Config.photoArray.append(PhotoData.init(isEdit: false, isRemove: false, photoUrl: photoUrl, photo: UIImage(named: "ic_photo_placeholder")!))
            }
        } else {
            cancelButton.isHidden = true
            backButton.isHidden = false
            titleLabel.text = localized("create_classified")
            Config.strDescription = ""
            
            for _ in 0..<6 {
                Config.photoArray.append(PhotoData.init(isEdit: false, isRemove: false, photoUrl: "", photo: UIImage(named: "ic_photo_placeholder")!))
            }
        }

        photoCollectionView.reloadData()
    }
    
    // MARK: UITapGestureRecognizer
    
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    // MARK: UITextField Delegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            priceTextField.becomeFirstResponder()
        }
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.priceTextField && string == "." {
            let countdots = textField.text?.components(separatedBy: ".")
            if (countdots?.count)! >= 2 {
                return false
            }
        }
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: Action
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchButtonPressed(_ sender: Any) {
        if isSwitchOn {
            isSwitchOn = false
            switchButton.setImage(UIImage(named: "ic_switch_off"), for: .normal)
        } else {
            isSwitchOn = true
            switchButton.setImage(UIImage(named: "ic_switch_on"), for: .normal)
        }
    }
    
    @IBAction func descriptionButtonPressed(_ sender: Any) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ClassifiedDescriptionViewController") as! ClassifiedDescriptionViewController
        self.navigationController?.present(nextViewController, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if nameTextField.text == "" {
            self.showAlert(message: localized("classified_name_error"))
            return
        } else if priceTextField.text == "" {
            self.showAlert(message: localized("classified_price_error"))
            return
        } else if descriptionLabel.text == localized("edit_description") {
            self.showAlert(message: localized("classified_description_error"))
            return
        } else {
            
            if Config.isEditClassified {
                if Config.photoArray[0].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[0].isEdit &&
                    Config.photoArray[1].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[1].isEdit &&
                    Config.photoArray[2].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[2].isEdit &&
                    Config.photoArray[3].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[3].isEdit &&
                    Config.photoArray[4].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[4].isEdit &&
                    Config.photoArray[5].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[5].isEdit {
                    self.showAlert(message: localized("classified_photo_error"))
                    return
                }
            } else {
                if Config.photoArray[0].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[1].photo == UIImage(named: "ic_photo_placeholder") &&
                    Config.photoArray[2].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[3].photo == UIImage(named: "ic_photo_placeholder") &&
                    Config.photoArray[4].photo == UIImage(named: "ic_photo_placeholder") && Config.photoArray[5].photo == UIImage(named: "ic_photo_placeholder") {
                    self.showAlert(message: localized("classified_photo_error"))
                    return
                }
            }
        }
        
        dismissKeyboard()
        
        var price = priceTextField.text!
        if isSwitchOn {
            price = price + localized("classified_hour")
        }
        
        Config.classifiedPreviewData = ClassifiedData.init(name: nameTextField.text!, price: price, desc: Config.strDescription)
        
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "PreviewClassifiedViewController") as! PreviewClassifiedViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Config.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 3 - 20, height: self.view.frame.width / 3 - 20)
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath)
        
        let classifiedImage = cell.viewWithTag(1) as? UIImageView
        let addButton = cell.viewWithTag(2) as? UIButton
        let editButton = cell.viewWithTag(3) as? UIButton
        
        addButton?.addTarget(self, action: #selector(self.addButtonClicked), for: .touchUpInside)
        editButton?.addTarget(self, action: #selector(self.editButtonClicked), for: .touchUpInside)
        
        if Config.isEditClassified {
            if Config.photoArray[indexPath.row].isEdit {
                if Config.photoArray[indexPath.row].photo == UIImage(named: "ic_photo_placeholder") {
                    addButton?.isHidden = false
                    editButton?.isHidden = true
                } else {
                    addButton?.isHidden = true
                    editButton?.isHidden = false
                }
                classifiedImage?.image = Config.photoArray[indexPath.row].photo
            } else {
                if Config.photoArray[indexPath.row].photoUrl == "" {
                    addButton?.isHidden = false
                    editButton?.isHidden = true
                    
                    classifiedImage?.image = Config.photoArray[indexPath.row].photo
                } else {
                    addButton?.isHidden = true
                    editButton?.isHidden = false
                    
                    classifiedImage?.sd_setImage(with: URL(string: Config.photoArray[indexPath.row].photoUrl), completed: { (image, error, type, url) in
                        if image != nil {
                            classifiedImage?.image = image
                            Config.photoArray[indexPath.row].photo = image!
                        }
                    })
                }
            }
        } else {
            if Config.photoArray[indexPath.row].photo == UIImage(named: "ic_photo_placeholder") {
                addButton?.isHidden = false
                editButton?.isHidden = true
            } else {
                addButton?.isHidden = true
                editButton?.isHidden = false
            }
            classifiedImage?.image = Config.photoArray[indexPath.row].photo
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
    }
    
    @objc func addButtonClicked(_ sender: Any) {
        let btn = sender as? UIButton
        let buttonFrameInTableView: CGRect? = btn?.convert(btn?.bounds ?? CGRect.zero, to: photoCollectionView)
        selectedIndex = photoCollectionView.indexPathForItem(at: buttonFrameInTableView?.origin ?? CGPoint.zero)
        
        onSelectPhoto()
    }
    
    @objc func editButtonClicked(_ sender: Any) {
        let btn = sender as? UIButton
        let buttonFrameInTableView: CGRect? = btn?.convert(btn?.bounds ?? CGRect.zero, to: photoCollectionView)
        selectedIndex = photoCollectionView.indexPathForItem(at: buttonFrameInTableView?.origin ?? CGPoint.zero)
        
        onEditPhoto()
    }
    
    func onSelectPhoto() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: localized("classified_camera"), style: .default , handler:{ (UIAlertAction) in
            self.openPhotoCamera()
        }))
        alert.addAction(UIAlertAction(title: localized("classified_library"), style: .default , handler:{ (UIAlertAction) in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: localized("generic_cancel"), style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        self.present(alert, animated: true, completion:nil)
    }
    
    func onEditPhoto() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: localized("classified_edit_photo"), style: .default , handler:{ (UIAlertAction) in
            self.onSelectPhoto()
        }))
        alert.addAction(UIAlertAction(title: localized("classified_remove_photo"), style: .destructive , handler:{ (UIAlertAction) in
            if Config.photoArray[self.selectedIndex.row].photoUrl == "" {
                Config.photoArray[self.selectedIndex.row].isEdit = false
                Config.photoArray[self.selectedIndex.row].isRemove = false
            } else {
                Config.photoArray[self.selectedIndex.row].isEdit = true
                Config.photoArray[self.selectedIndex.row].isRemove = true
            }
            Config.photoArray[self.selectedIndex.row].photo = UIImage(named: "ic_photo_placeholder")!
            self.photoCollectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: localized("generic_cancel"), style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        self.present(alert, animated: true, completion:nil)
    }
    
    // MARK: Camera Action
    
    func openPhotoCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            pickerController.delegate = self
            self.pickerController.sourceType = UIImagePickerControllerSourceType.camera
            pickerController.mediaTypes = [kUTTypeImage as String]
            pickerController.allowsEditing = false
            self.present(self.pickerController, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            pickerController.mediaTypes = [kUTTypeImage as String]
            pickerController.allowsEditing = false
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: UIImagePickerController Delegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        image = image.fixOrientation()
        
        var scaleWidth = UIScreen.main.bounds.width
        if scaleWidth > image.size.width {
            scaleWidth = image.size.width
        }
        
        Config.photoArray[self.selectedIndex.row].isEdit = true
        Config.photoArray[self.selectedIndex.row].photo = image.resizeImage(image: image, newWidth: scaleWidth)
        photoCollectionView.reloadData()
        
        dismiss(animated:true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
}
