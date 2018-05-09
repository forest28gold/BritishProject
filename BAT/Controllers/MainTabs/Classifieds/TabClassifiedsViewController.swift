//
//  TabClassifiedsViewController.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit
import PullToRefresh
import Parse

class TabClassifiedsViewController: Controller, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var classifiedView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var classifiedTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var emptySearchBar: UISearchBar!
    
    var is_load = false
    var classifieds = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadLayout()
        loadClassifiedsData(isEmpty: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if is_load {
            self.refreshClassifiedsData()
        }
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
        
        for subView in searchBar.subviews {
            for subsubView in subView.subviews {
                if let textField = subsubView as? UITextField {
                    textField.backgroundColor = colorHEX("000000").withAlphaComponent(0.08)
                    textField.font = UIFont(name: "SanFranciscoText-Regular", size: 15)
                    textField.textColor = colorHEX("8E8E93")
                }
            }
        }
        
        for subView in emptySearchBar.subviews {
            for subsubView in subView.subviews {
                if let textField = subsubView as? UITextField {
                    textField.backgroundColor = colorHEX("000000").withAlphaComponent(0.08)
                    textField.font = UIFont(name: "SanFranciscoText-Regular", size: 15)
                    textField.textColor = colorHEX("8E8E93")
                }
            }
        }
        
        self.searchBar.delegate = self
        self.emptySearchBar.delegate = self
        
        classifiedTableView.addPullToRefresh(PullToRefresh()) { [weak self] in
            if (self?.is_load)! {
                self?.refreshClassifiedsData()
            }
        }
    }
    
    // MARK: Load Classifieds Data
    
    func loadClassifiedsData(isEmpty: Bool) {
        
        Config.classifiedArray.removeAll()
        self.showLoading(status: localized("generic_wait"))
        
        let query = PFQuery(className: Const.ParseClass.ClassifiedsClass)
        query.includeKey("user")
        query.whereKey("isEnabled", equalTo:true)
        query.order(byDescending: "createdAt")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.stopLoading()
            self.is_load = true
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        Config.classifiedArray.append(object)
                    }
                    
                    if isEmpty {
                        self.filterClassifiedData(searchText: self.emptySearchBar.text!)
                    } else {
                        self.classifieds = Config.classifiedArray
                    }
                    
                    if self.classifieds.count > 0 {
                        self.classifiedTableView.reloadData()
                        self.emptyView.isHidden = true
                        self.classifiedView.isHidden = false
                    } else {
                        self.emptyView.isHidden = false
                        self.classifiedView.isHidden = true
                    }
                } else {
                    self.emptyView.isHidden = false
                    self.classifiedView.isHidden = true
                }
            } else {
                self.emptyView.isHidden = false
                self.classifiedView.isHidden = true
            }
        })
    }
    
    func refreshClassifiedsData() {
        
        let query = PFQuery(className: Const.ParseClass.ClassifiedsClass)
        query.includeKey("user")
        query.whereKey("isEnabled", equalTo:true)
        query.order(byDescending: "createdAt")
        query.limit = QUERY_LIMIT
        query.findObjectsInBackground (block: { (objects, error) in
            
            self.classifiedTableView.endRefreshing(at: .top)
            Config.classifiedArray.removeAll()
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        Config.classifiedArray.append(object)
                    }
                    
                    self.filterClassifiedData(searchText: self.searchBar.text!)
                    
                    if Config.classifiedArray.count > 0 {
                        
                        UIView.performWithoutAnimation {
                            let range = NSMakeRange(0, self.classifiedTableView.numberOfSections)
                            let sections = NSIndexSet(indexesIn: range)
                            self.classifiedTableView.reloadSections(sections as IndexSet, with: .none)
                        }
                        
                        self.emptyView.isHidden = true
                        self.classifiedView.isHidden = false
                    } else {
                        self.emptyView.isHidden = false
                        self.classifiedView.isHidden = true
                    }
                } else {
                    self.emptyView.isHidden = false
                    self.classifiedView.isHidden = true
                }
            } else {
                self.emptyView.isHidden = false
                self.classifiedView.isHidden = true
            }
        })
    }
    
    // MARK: UISearchBar

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
//        if searchBar == self.emptySearchBar {
//            self.loadClassifiedsData(isEmpty: true)
//        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar == self.searchBar {
//            self.filterClassifiedData(searchText: searchText)
//            self.classifiedTableView.reloadData()
//        }
        
        self.filterClassifiedData(searchText: searchText)
        self.classifiedTableView.reloadData()
    }
    
    func filterClassifiedData(searchText: String) {
        if searchText == "" {
            self.classifieds = Config.classifiedArray
        } else {
            self.classifieds = Config.classifiedArray.filter({ (classifiedObject) -> Bool in
                let classifiedName = Config.onCheckStringNull(object: classifiedObject, key: "name")
                let tmp: NSString = classifiedName as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
        }
    }
    
    // MARK: Action
    
    @IBAction func emptyAddButtonPressed(_ sender: Any) {
        Config.isEditClassified = false
        Config.strDescription = ""
        Config.tabBarCtrl?.onEditClassified()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        Config.isEditClassified = false
        Config.strDescription = ""
        Config.tabBarCtrl?.onEditClassified()
    }
    
    @IBAction func newButtonPressed(_ sender: Any) {
        Config.isEditClassified = false
        Config.strDescription = ""
        Config.tabBarCtrl?.onEditClassified()
    }
    
    // MARK: UITableView Delegate
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classifieds.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 154
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassifiedCell", for: indexPath as IndexPath)
        
        let classifiedImage = cell.viewWithTag(1) as? UIImageView
        let nameLable = cell.viewWithTag(2) as? UILabel
        let descriptionLable = cell.viewWithTag(3) as? UILabel
        let priceLable = cell.viewWithTag(4) as? UILabel
        
        classifiedImage?.layer.cornerRadius = (classifiedImage?.frame.size.height)! / 2
        
        let classifiedData = self.classifieds[indexPath.row]
        
        nameLable?.text = Config.onCheckStringNull(object: classifiedData, key: "name")
        descriptionLable?.text = Config.onCheckStringNull(object: classifiedData, key: "desc")
        priceLable?.text = Config.onCheckStringNull(object: classifiedData, key: "price")
        
        let photo1 = Config.onCheckFileNull(object: classifiedData, key: "photo1")
        let photo2 = Config.onCheckFileNull(object: classifiedData, key: "photo2")
        let photo3 = Config.onCheckFileNull(object: classifiedData, key: "photo3")
        let photo4 = Config.onCheckFileNull(object: classifiedData, key: "photo4")
        let photo5 = Config.onCheckFileNull(object: classifiedData, key: "photo5")
        let photo6 = Config.onCheckFileNull(object: classifiedData, key: "photo6")
        
        if photo1 != "" {
            classifiedImage?.sd_setImage(with: URL(string: photo1), placeholderImage: UIImage(named: "ic_placeholder"))
        } else {
            if photo2 != "" {
                classifiedImage?.sd_setImage(with: URL(string: photo2), placeholderImage: UIImage(named: "ic_placeholder"))
            } else {
                if photo3 != "" {
                    classifiedImage?.sd_setImage(with: URL(string: photo3), placeholderImage: UIImage(named: "ic_placeholder"))
                } else {
                    if photo4 != "" {
                        classifiedImage?.sd_setImage(with: URL(string: photo4), placeholderImage: UIImage(named: "ic_placeholder"))
                    } else {
                        if photo5 != "" {
                            classifiedImage?.sd_setImage(with: URL(string: photo5), placeholderImage: UIImage(named: "ic_placeholder"))
                        } else {
                            if photo6 != "" {
                                classifiedImage?.sd_setImage(with: URL(string: photo6), placeholderImage: UIImage(named: "ic_placeholder"))
                            } else {
                                classifiedImage?.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "ic_placeholder"))
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        Config.classifiedData = self.classifieds[indexPath.row]
        Config.tabBarCtrl?.onClassifiedDetails()
    }
}
