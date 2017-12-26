//
//  Courses.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 12/25/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import Foundation
import WebKit

class Courses: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var open: UIBarButtonItem!
    
    override func viewDidLoad() {
        // Makes the hamburger menu reveal
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Recognize right swipe gesture
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
}
