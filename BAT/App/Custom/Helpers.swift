//
//  Helpers.swift
//  BAT
//
//  Created by AppsCreationTech on 1/19/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import Foundation
import UIKit

extension FileManager {
    class var cachesUrl: URL {
        get {
            return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
        }
    }
    
    class func fileUrlInsideCacheDir(_ fileName: String) -> URL {
        return cachesUrl.appendingPathComponent(fileName)
    }
}

func future(_ closure:@escaping ()->()) {
    let backQueue = DispatchQueue(label: "future", attributes: .concurrent)
    backQueue.async(execute: closure)
}

func delayCall(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func ui(_ closure:@escaping ()->()){
    DispatchQueue.main.async(execute: closure)
}

class LocalizedLabel : UILabel {
    override func awakeFromNib() {
        if let text = text {
            let attributedString = NSMutableAttributedString(string: NSLocalizedString(text, comment: ""))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self.attributedText = attributedString;
        }
    }
}

class LocalizedCenterLabel : UILabel {
    override func awakeFromNib() {
        if let text = text {
            let attributedString = NSMutableAttributedString(string: NSLocalizedString(text, comment: ""))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = 5
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self.attributedText = attributedString;
        }
    }
}
