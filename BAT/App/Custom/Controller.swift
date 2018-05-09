//
//  Controller.swift
//
//  Created by Benjamin Bourasseau on 20/01/2016.
//  Copyright © 2016 Benjamin. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import SDWebImage

/* Controller class tu use your custom Navigation item */
public class Controller: UIViewController, NavItemDelegate, ShowsAlert {
    
    var navItem: NavItem?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: Errors and loading
    
    func showLoading() {
        SVProgressHUD.show()
    }
    
    func showLoading(status: String) {
        SVProgressHUD.show(withStatus: status)
    }
    
    func stopLoading() {
        SVProgressHUD.dismiss()
    }
    
    func showError(err: String) {
        SVProgressHUD.showError(withStatus: err)
    }
    
    func showSuccess(success: String) {
        SVProgressHUD.showSuccess(withStatus: success)
    }
}
