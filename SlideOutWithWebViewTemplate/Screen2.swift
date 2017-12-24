//
//  Screen2.swift
//  SlideOutMenuTemplate
//
//  Created by Kyle Swearingen on 12/10/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import Foundation
import WebKit

class Screen2: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        // Makes the hamburger menu reveal
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Recognize right swipe gesture
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        let url = URL(string: "https://www.google.com")
        let request = URLRequest(url: url!)
        
        webView.load(request)
    }
}
