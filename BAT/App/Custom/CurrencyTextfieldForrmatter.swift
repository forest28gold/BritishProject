//
//  CurrencyTextfieldForrmatter.swift
//  BAT
//
//  Created by AppsCreationTech on 1/26/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class CurrencyTextfieldForrmatter : UITextField {
    @IBInspectable var maxDigits:Int = 15
    fileprivate var defaultValue: Double = 0
    fileprivate let currencyFormattor = NumberFormatter()
    fileprivate var previousValue : String = ""
    var previousDouble: String = ""
    @IBInspectable var isFractionExist: Bool = true
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initTextField()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTextField()
    }
    
    func initTextField() {
        self.keyboardType = UIKeyboardType.decimalPad
        currencyFormattor.numberStyle = .currency
        currencyFormattor.minimumFractionDigits = 0
        currencyFormattor.maximumFractionDigits = 2
        currencyFormattor.currencySymbol = "$ "
        setAmount(defaultValue)
    }
    
    // MARK: - UITextField Notifications
    
    override open func willMove(toSuperview newSuperview: UIView!) {
        if newSuperview != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name:NSNotification.Name.UITextFieldTextDidChange, object: self)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc func textDidChange(_ notification: Notification){
        let cursorOffset = getOriginalCursorPosition();
        var cleanNumericString : String = getCleanNumberString()
        var isFraction = false
        let textFieldLength = self.text?.count
        
        if self.isFractionExist {
            if let dotIndex = self.text?.encodedOffset(of: ".") {
                if cleanNumericString.count == 1 && cleanNumericString == "." {
                    self.text = "$ 0."
                }
                let toArray = cleanNumericString.components(separatedBy: ".")
                if toArray[1].count > 2 && cursorOffset == self.text?.count {
                    self.text?.removeLast()
                    return
                }
                if toArray[1].count > 2 {
                    if dotIndex < cursorOffset {
                        self.text = self.previousDouble
                        setCursorOriginalPosition(cursorOffset, oldTextFieldLength: textFieldLength)
                        return
                    }
                    let dot = cleanNumericString.index(of: ".")
                    cleanNumericString.remove(at: dot!)
                } else {
                    if cursorOffset > dotIndex && cursorOffset == self.text?.count && cleanNumericString.count > 1 {
                        isFraction = true
                    } else {
                        if cleanNumericString.count == 1 {
                            isFraction = true
                        } else {
                            isFraction = false
                        }
                    }
                }
            } else if cleanNumericString.count == 1 && cleanNumericString == "0" {
                isFraction = true
                self.text = "$ 0"
            }
        }
        maxDigits = cleanNumericString.contains(".") && self.isFractionExist ? (maxDigits+3) : maxDigits
        if cleanNumericString.count > maxDigits {
            self.text = previousValue
        } else {
            if !isFraction {
                let textFieldNumber = Double(cleanNumericString)
                if let textFieldNumber = textFieldNumber{
                    let textFieldNewValue = textFieldNumber
                    setAmount(textFieldNewValue)
                } else {
                    self.text = ""
                }
            }
        }
        self.previousDouble = self.text ?? ""
        //Set the cursor back to its original poistion
        setCursorOriginalPosition(cursorOffset, oldTextFieldLength: textFieldLength)
    }
    
    //MARK: - Custom text field functions
    
    func setAmount (_ amount : Double) {
        if amount != 0 {
            let textFieldStringValue = currencyFormattor.string(from: NSNumber(value: amount))
            self.text = textFieldStringValue
            if let textFieldStringValue = textFieldStringValue {
                previousValue = textFieldStringValue
            }
        } else {
            self.text = ""
        }
    }
    
    //MARK - helper functions
    
    fileprivate func getCleanNumberString() -> String {
        var cleanNumericString: String = ""
        let textFieldString = self.text
        if let textFieldString = textFieldString{
            
            //Remove $ sign
            var toArray = textFieldString.components(separatedBy: "$ ")
            cleanNumericString = toArray.joined(separator: "")
            
            //Remove periods, commas
            toArray = cleanNumericString.components(separatedBy: ",")
            cleanNumericString = toArray.joined(separator: "")
        }
        return cleanNumericString
    }
    
    fileprivate func getOriginalCursorPosition() -> Int {
        
        var cursorOffset : Int = 0
        let startPosition : UITextPosition = self.beginningOfDocument
        if let selectedTextRange = self.selectedTextRange {
            cursorOffset = self.offset(from: startPosition, to: selectedTextRange.start)
        }
        return cursorOffset
    }
    
    fileprivate func setCursorOriginalPosition(_ cursorOffset: Int, oldTextFieldLength : Int?) {
        
        let newLength = self.text?.count
        let startPosition : UITextPosition = self.beginningOfDocument
        if let oldTextFieldLength = oldTextFieldLength, let newLength = newLength, oldTextFieldLength > cursorOffset {
            let newOffset = newLength - oldTextFieldLength + cursorOffset
            let newCursorPosition = self.position(from: startPosition, offset: newOffset)
            if let newCursorPosition = newCursorPosition {
                let newSelectedRange = self.textRange(from: newCursorPosition, to: newCursorPosition)
                self.selectedTextRange = newSelectedRange
            }
            
        }
    }
}

extension String {
    func encodedOffset(of character: Character) -> Int? {
        return index(of: character)?.encodedOffset
    }
    func encodedOffset(of string: String) -> Int? {
        return range(of: string)?.lowerBound.encodedOffset
    }
}
