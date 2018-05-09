//
//  FLNavItem.swift
//
//  Created by Benjamin Bourasseau on 20/01/2016.
//  Copyright © 2016 Benjamin. All rights reserved.
//

import Foundation
import UIKit

public enum NavPos {
    case left, right
}

public enum NavItemStyle {
    case black, orange, white
    
    // Color of Navbar title
    var titleColor: UIColor {
        switch self {
        case .black:
            return UIColor.black
        case .orange:
            return UIColor.orange
        case .white:
            return UIColor.white
        }
    }
    
    // Color of Navbar text
    var textColor: UIColor {
        switch self {
        case .black:
            return UIColor.black
        case .orange:
            return UIColor.orange
        case .white:
            return UIColor.white
        }
    }
    
    // Font of Navbar title
    var titleFont: UIFont {
        return Fonts.HelveticaNeue.light.size(18.0)
    }
    
    // Font of Navbar text
    var textFont: UIFont {
        return Fonts.HelveticaNeue.light.size(15.0)
    }
    
    var backgroundColor: UIColor {
        return UIColor.clear
    }
}

@objc protocol NavItemDelegate {
    @objc optional func navItemDidTapLeftButton()
    @objc optional func navItemDidTapRightButton()
    @objc optional func navItemDidTapBack()
}

public final class NavItem: UINavigationItem {
    
    var navItemStyle: NavItemStyle = .black {
        didSet {
            updateTextAttr()
        }
    }
    
    var defaultTextAttr: [NSAttributedStringKey: Any] = [:]
    
    var controller: UIViewController
    
    weak var delegate: NavItemDelegate?
    
    // This is a temporary fix for the swipe gesture on back button
    var backSwipeEnabled = false {
        didSet {
            if backSwipeEnabled {
                guard let recognizer = controller.navigationController?.interactivePopGestureRecognizer else {
                    return
                }
                if let recognizers = controller.view.gestureRecognizers {
                    if !recognizers.contains(recognizer) {
                        controller.view.addGestureRecognizer(recognizer)
                        controller.navigationController?.interactivePopGestureRecognizer?.delegate = self
                    }
                } else {
                    controller.view.addGestureRecognizer(recognizer)
                    controller.navigationController?.interactivePopGestureRecognizer?.delegate = self
                }
            } else {
                if let recognizer = controller.navigationController?.interactivePopGestureRecognizer {
                    controller.navigationController?.view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    /*! Default initializer */
    public init(title: String, controller: UIViewController) {
        self.controller = controller
        super.init(title: title)
        updateTextAttr()
        disableBackButton()
    }
    
    private func disableBackButton() {
        self.hidesBackButton = true
        self.backSwipeEnabled = false
    }
    
    private func updateTextAttr() {
        self.defaultTextAttr = [NSAttributedStringKey.foregroundColor: self.navItemStyle.textColor, NSAttributedStringKey.font: self.navItemStyle.textFont]
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Generic Functions
    
    private func setBarButtonItem(_ buttonItem: UIBarButtonItem, pos: NavPos) {
        if pos == .left {
            self.setLeftBarButton(buttonItem, animated: false)
        } else {
            self.setRightBarButton(buttonItem, animated: false)
        }
    }
    
    private func setBarButtonItemArray(_ buttonItems: [UIBarButtonItem], pos: NavPos) {
        if pos == .left {
            self.setLeftBarButtonItems(buttonItems, animated: false)
        } else {
            self.setRightBarButtonItems(buttonItems, animated: false)
        }
    }
    
    // MARK: Buttons Items
    
    public func setText(_ text: String, pos: NavPos, attr: [NSAttributedStringKey: Any]? = [:]) {
        
        let attributes: [NSAttributedStringKey: Any]
        if let attr = attr {
            if attr.count > 0 {
                attributes = attr
            } else {
                attributes = defaultTextAttr
            }
        } else {
            attributes = defaultTextAttr
        }
        
        var aBarButtonItem: UIBarButtonItem
        if pos == .left {
            aBarButtonItem = UIBarButtonItem(title: text, style: .plain, target: self, action: #selector(tapLeft))
        } else {
            aBarButtonItem = UIBarButtonItem(title: text, style: .plain, target: self, action: #selector(tapRight))
        }
        aBarButtonItem.setTitleTextAttributes(attributes, for: .normal)
        self.setBarButtonItem(aBarButtonItem, pos: pos)
    }
    
    /// Create a custom Navigation Item button. Just provide the position - Left or Right
    public func setCustomButton(_ pos: NavPos, image: UIImage, size: CGSize) {
        let aButton: UIButton = UIButton(type: .custom)
        aButton.setBackgroundImage(image, for: .normal)
        aButton.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if pos == .left {
            aButton.addTarget(self, action: #selector(tapLeft), for: .touchUpInside)
        } else {
            aButton.addTarget(self, action: #selector(tapRight), for: .touchUpInside)
        }
        let aBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: aButton)
        self.setBarButtonItem(aBarButtonItem, pos: pos)
    }
    
    public func setNavButton(_ button: NavButton, atPos pos: NavPos) {
        self.setCustomButton(pos, image: button.image, size: button.size)
    }
    
    public func setClose(_ pos: NavPos) {
        self.setNavButton(Const.NavButtons.close, atPos: pos)
    }
}

// MARK: Back

extension NavItem {
    
    /* Back function */
    func setBack() {
        let buttonImage: UIImage? = UIImage(named: "navbarBack")
        if let buttonImg = buttonImage {
            let aButton: UIButton = UIButton(type: .custom)
            aButton.setBackgroundImage(buttonImg, for: .normal)
            aButton.frame = CGRect(x: 0, y: 0, width: 14, height: 26)
            aButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            
            let aBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: aButton)
            self.setLeftBarButton(aBarButtonItem, animated: false)
            self.backSwipeEnabled = true
        } else {
            print("Back button not loaded")
        }
    }
}

// MARK: Actions

extension NavItem {
    
    /* Back action. if not set, the default is to pop the view controller */
    @objc public func backAction() {
        if let del = delegate {
            if let back = del.navItemDidTapBack {
                back()
            } else {
                // Back action not implemented, we use the normal back
                _ = self.controller.navigationController?.popViewController(animated: true)
            }
        } else {
            _ = self.controller.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc public func tapRight(_ sender: AnyObject) {
        if let del = delegate {
            if let tapRightMethod = del.navItemDidTapRightButton {
                tapRightMethod()
                return
            }
        }
    }
    
    @objc public func tapLeft(_ sender: AnyObject) {
        if let del = delegate {
            if let tapLeftMethod = del.navItemDidTapLeftButton {
                tapLeftMethod()
            }
        }
    }
}

extension NavItem {
    
    /// Update the navItem for the controller, Call it in viewWillAppear
    func update() {
        self.updateNavBar()
        self.setup()
    }
    
    private func setup() {
        let vc: UIViewController = self.controller as UIViewController
        vc.navigationItem.title = self.title
        vc.navigationItem.prompt = self.prompt
        vc.navigationItem.hidesBackButton = self.hidesBackButton
        vc.navigationItem.backBarButtonItem = self.backBarButtonItem
        vc.navigationItem.leftBarButtonItem = self.leftBarButtonItem
        vc.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        vc.navigationItem.leftBarButtonItems = self.leftBarButtonItems
        vc.navigationItem.rightBarButtonItems = self.rightBarButtonItems
        vc.navigationItem.titleView = self.titleView
    }
    
    /*! Set navbar as global nav bar display */
    private func updateNavBar() {
        if let nav = self.controller.navigationController {
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.tintColor = UIColor.clear
            nav.navigationBar.isTranslucent = true
            nav.view.backgroundColor = UIColor.clear
            nav.navigationBar.backgroundColor = self.navItemStyle.backgroundColor
            let attr = [NSAttributedStringKey.foregroundColor: self.navItemStyle.titleColor, NSAttributedStringKey.font: self.navItemStyle.titleFont]
            nav.navigationBar.titleTextAttributes = attr
        }
    }
}

extension NavItem: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
