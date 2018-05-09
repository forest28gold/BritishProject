//
//  PollCell.swift
//  BAT
//
//  Created by AppsCreationTech on 1/22/18.
//  Copyright © 2018 AppsCreationTech. All rights reserved.
//

import UIKit

class PollCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var contentLable: UILabel!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var answerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nbLikesCommentsLable: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
