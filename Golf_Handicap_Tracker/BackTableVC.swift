//
//  BackTableVC.swift
//  SlideOutMenuTemplate
//
//  Created by Kyle Swearingen on 12/10/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import Foundation
import os.log

class BackTableVC: UITableViewController {
    
    //MARK: Variables
    var tableArray = [String]()
    
    //MARK: Functions
    override func viewDidLoad() {
        tableArray = ["Courses", "Scores", "About Me"]
        self.tableView.backgroundColor = UIColor.lightGray
        
        if let savedAboutMe = loadAboutMe() {
            self.title = "Welcome " + savedAboutMe.firstName + "!"
        }
        else {
            self.title = "Welcome!"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableArray[indexPath.row], for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = tableArray[indexPath.row]
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.lightGray
        
        return cell
    }
    
    //MARK: Private Methods
    func loadAboutMe() -> AboutMe? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: AboutMe.ArchiveURL.path) as? AboutMe
    }
    
}
