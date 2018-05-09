//
//  TermsOfUseViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/20/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit

class TermsOfUseViewController: Controller {
   
    @IBOutlet var titleLable: UILabel!
    @IBOutlet var contentTextView: UITextView!

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
        titleLable.text = Config.strTerms
        contentTextView.isEditable = false
    }
    
    // MARK: Action

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
