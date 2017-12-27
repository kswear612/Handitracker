//
//  CoursesTableViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 12/26/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log

class CoursesTableViewController: UITableViewController {

    //MARK: Properties
    @IBOutlet weak var open: UIBarButtonItem!
    var courses = [Course]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Makes the hamburger menu reveal
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Recognize right swipe gesture
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Load any saved courses, otherwise load sample data
        loadSampleCourses()
        /*if let savedCourses = loadCourses() {
            courses += savedCourses
        }
        else {
            // Load the sample data
            loadSampleCourses()
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows that will be shown in the table
        return courses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CourseTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CourseTableViewCell else {
            fatalError("The dequeued cell is not an instance of CourseTableViewCell")
        }

        // Fetches the appropriate course for the data source layout
        let course = courses[indexPath.row]
        
        cell.courseNameLabel.text = course.courseName
        cell.photoImageView.image = course.photo
        cell.courseRatingLabel.text = course.courseRating.description
        cell.courseSlopeLabel.text = course.courseSlope.description

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            courses.remove(at: indexPath.row)
            saveCourses()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }*/
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Private Methods
    private func loadSampleCourses() {
        let photo1 = UIImage(named: "Pebble Beach")
        let photo2 = UIImage(named: "Bethpage Black")
        let photo3 = UIImage(named: "Masters")
        
        guard let course1 = Course(courseName: "Pebble Beach", photo: photo1, courseRating: 112.0, courseSlope: 35.0) else {
            fatalError("Unale to instantiate Pebble Beach")
        }
        
        guard let course2 = Course(courseName: "Bethpage Black", photo: photo2, courseRating: 120.0, courseSlope: 38.3) else {
            fatalError("Unale to instantiate Bethpage Black")
        }
        
        guard let course3 = Course(courseName: "Masters", photo: photo3, courseRating: 146.0, courseSlope: 42.5) else {
            fatalError("Unale to instantiate Masters")
        }
        
        courses += [course1, course2, course3]
    }
    
    /*private func saveCourses() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(courses, toFile: Course.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save meals...", log: OSLog.default, type: .debug)
        }
    }
    
    private func loadCourses() -> [Course]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Course.ArchiveURL.path) as? [Course]
    }*/
}
