//
//  ClassifiedDescriptionViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit

class ClassifiedDescriptionViewController: Controller, UITextViewDelegate {

    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: .UIKeyboardDidHide, object: nil)
        
        if Config.strDescription == "" {
            saveButton.isEnabled = false
            descriptionTextView.text = localized("classified_description")
            descriptionTextView.textColor = colorHEX("D8D8D8")
        } else {
            saveButton.isEnabled = true
            descriptionTextView.text = Config.strDescription
            descriptionTextView.textColor = colorHEX("928F8F")
        }
    }
    
    // MARK: UITapGestureRecognizer
    
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    // MARK: UIKeyboard notification
    
    @objc func keyBoardDidShow(notification: NSNotification) {
        //handle appearing of keyboard here
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            var frame = self.descriptionTextView.frame
            frame.size.height = self.view.frame.size.height - keyboardHeight - 64 - 85
            self.descriptionTextView.frame = frame
        }
    }
    
    @objc func keyBoardDidHide(notification: NSNotification) {
        //handle dismiss of keyboard here
        
        var frame = self.descriptionTextView.frame
        frame.size.height = self.view.frame.size.height - 64 - 35
        self.descriptionTextView.frame = frame
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: UITextView Delegate
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.text == localized("classified_description") {
            descriptionTextView.text = ""
        }
        descriptionTextView.textColor = colorHEX("928F8F")
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if changedText.count > 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        return true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            descriptionTextView.text = localized("classified_description")
        }
    }
    
    // MARK: Action

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if descriptionTextView.text.count == 0 {
            self.showAlert(message: localized("classified_description_error"))
            return
        }
        
        dismissKeyboard()
        
        Config.strDescription = descriptionTextView.text
        
        self.dismiss(animated: true, completion: nil)
    }
}
