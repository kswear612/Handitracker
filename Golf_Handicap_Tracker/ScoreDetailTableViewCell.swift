//
//  ScoreDetailTableViewCell.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/22/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import UIKit

class ScoreDetailTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var holeStrokesLabel: UILabel!
    @IBOutlet weak var holeStrokesSlider: UISlider!
    @IBOutlet weak var holeNumberLabel: UILabel!
    
    @IBAction func strokeSlider(_ sender: UISlider) {
        holeStrokesLabel.text = String(Int(sender.value))
    }
}
