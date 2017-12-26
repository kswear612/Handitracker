//
//  ViewController.swift
//  SlideOutMenuTemplate
//
//  Created by Kyle Swearingen on 12/10/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var label: UILabel!
    
    var varView = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Makes the open button do the reveal action
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Recognize right swipe gesture
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

