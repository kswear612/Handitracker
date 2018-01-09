//
//  ScoresTableViewCell.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/2/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import UIKit

class ScoresTableViewCell: UITableViewCell {

    //MARK: Properites
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
