//
//  CoursesTableViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 12/26/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log
import CoreGraphics

class CoursesTableViewController: UITableViewController {

    //MARK: Properties
    @IBOutlet weak var open: UIBarButtonItem!
    var courses = [Course]()
    var scores = [Score]()
    var courseHandicapDifferentials = [String: [Double]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Makes the hamburger menu reveal
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Use the edit button item provided by the table view controller
        //navigationItem.leftBarButtonItem = editButtonItem
        
        // Recognize right swipe gesture
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Load any saved courses, otherwise load sample data
        if let savedCourses = loadCourses() {
            courses += savedCourses
            //loadSampleCourses()
        }
        else {
            // Load the sample data
            loadSampleCourses()
        }
        
        // Load any saved scores
        if let savedScores = loadScores() {
            scores += savedScores
        }
        
        calculateHandicapDifferentials()
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
        cell.handicapScore.text = calculateCourseHandicap(course: course);

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            courses.remove(at: indexPath.row)
            saveCourses()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.borderColor = UIColor.init(red: 3/255, green: 121/255, blue: 0/255, alpha: 1.0).cgColor
        cell.contentView.layer.borderWidth = 1
        
        // set up your background color view
        let colorView = UIView()
        colorView.backgroundColor = UIColor.lightGray
        
        // use UITableViewCell.appearance() to configure
        // the default appearance of all UITableViewCells in your app
        UITableViewCell.appearance().selectedBackgroundView = colorView
    }

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new course", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let courseDetailViewController = segue.destination as? CourseViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCourseCell = sender as? CourseTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCourseCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedCourse = courses[indexPath.row]
            courseDetailViewController.course = selectedCourse
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToCourseList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CourseViewController, let course = sourceViewController.course {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing course
                courses[selectedIndexPath.row] = course
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new course
                let newIndexPath = IndexPath(row: courses.count, section: 0)
                courses.append(course)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the courses
            saveCourses()
        }
    }
    
    @IBAction func unwindToCourseListFromCancel(sender: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

    //MARK: Private Methods
    private func loadSampleCourses() {
        let photo1 = UIImage(named: "Pebble Beach")
        let photo2 = UIImage(named: "Bethpage Black")
        let photo3 = UIImage(named: "Masters")
        
        guard let course1 = Course(courseName: "Pebble Beach", photo: photo1, courseRating: 72.2, courseSlope: 120, isNineHoleCourse: false) else {
            fatalError("Unale to instantiate Pebble Beach")
        }
        
        guard let course2 = Course(courseName: "Bethpage Black", photo: photo2, courseRating: 70.3, courseSlope: 130, isNineHoleCourse: true) else {
            fatalError("Unale to instantiate Bethpage Black")
        }
        
        guard let course3 = Course(courseName: "Masters", photo: photo3, courseRating: 65.8, courseSlope: 140, isNineHoleCourse: false) else {
            fatalError("Unale to instantiate Masters")
        }
        
        courses += [course1, course2, course3]
    }
    
    private func saveCourses() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(courses, toFile: Course.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Courses successfully saved", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save courses...", log: OSLog.default, type: .debug)
        }
    }
    
    func loadCourses() -> [Course]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Course.ArchiveURL.path) as? [Course]
    }
    
    func loadScores() -> [Score]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Score.ArchiveURL.path) as? [Score]
    }
    
    // Generates the
    func calculateHandicapDifferentials() {
        // Make sure we have both scores and courses
        if (courses.count > 0 && scores.count > 0) {
            // Loop through the courses and see if we have any scores
            for course in courses {
                var courseDifferentials = [Double]()
                // For each score see if the score was at one of our courses
                for score in scores {
                    if (score.courseName == course.courseName) {
                        let differentialFormatter = NumberFormatter()
                        differentialFormatter.minimumFractionDigits = 0
                        differentialFormatter.maximumFractionDigits = 1
                        differentialFormatter.roundingMode = .halfUp
                        
                        // We need to calculate the differential and add it to our array
                        let differential = (Double(score.score) - course.courseRating) * 113/Double(course.courseSlope)
                        courseDifferentials.append(Double(differentialFormatter.string(for: differential)!)!)
                    }
                }
                courseHandicapDifferentials[course.courseName] = courseDifferentials
            }
        }
    }
    
    // First calculate the handicap index for the course then use that to calculate the handicap
    func calculateCourseHandicap(course: Course) -> String {
        var courseHandicap = 0
        var handicapIndex = 0.0
        guard let courseIndexes = courseHandicapDifferentials[course.courseName]?.sorted() else {
            fatalError("No course indexes found")
        }
        
        if courseIndexes.count < 5 {
            return "N/A"
        }
            
        handicapIndex = calculateHandicapIndex(courseIndexes: courseIndexes, isNineHoleCourse: course.isNineHoleCourse)
        
        let handicapFormatter = NumberFormatter()
        handicapFormatter.minimumFractionDigits = 0
        handicapFormatter.maximumFractionDigits = 0
        handicapFormatter.roundingMode = .halfUp
        
        // Handicap Index * Slope / 113
        courseHandicap = Int(handicapFormatter.string(for: Double(handicapIndex * Double(course.courseSlope)/113.0))!)!
       
        
        return String(courseHandicap)
    }
    
    // Calculates the handicap index as a double truncated to the nearest tenth
    func calculateHandicapIndex(courseIndexes: [Double], isNineHoleCourse: Bool) -> Double {
        var handicapIndex = 0.0
        
        // Formatter for the handicap index to the nearest tenth
        let indexFormatter = NumberFormatter()
        indexFormatter.minimumFractionDigits = 0
        indexFormatter.maximumFractionDigits = 1
        indexFormatter.roundingMode = .down
        
        if courseIndexes.count >= 5 && courseIndexes.count <= 6 {
            // Retrieve only the lowest one
            handicapIndex = courseIndexes[0] * 0.96
        }
        else if courseIndexes.count > 6 && courseIndexes.count <= 8 {
            // Retrieve the lowest 2
            var handicapSum = 0.0
            for i in 0...2 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 2.0
            handicapIndex = handicapAverage * 0.96
        }
        else if courseIndexes.count > 8 && courseIndexes.count <= 10 {
            // Retrieve the lowest 3
            var handicapSum = 0.0
            for i in 0...3 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 3.0
            handicapIndex = handicapAverage * 0.96
        }
        else if courseIndexes.count > 10 && courseIndexes.count <= 12 {
            // Retrieve the lowest 4
            var handicapSum = 0.0
            for i in 0...4 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 4.0
            handicapIndex = handicapAverage * 0.96
        }
        else if courseIndexes.count > 12 && courseIndexes.count <= 14 {
            // Retrieve the lowest 5
            var handicapSum = 0.0
            for i in 0...5 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 5.0
            handicapIndex = handicapAverage * 0.96
        }
        else if courseIndexes.count > 14 && courseIndexes.count <= 16 {
            // Retrieve the lowest 6
            var handicapSum = 0.0
            for i in 0...6 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 6.0
            handicapIndex = handicapAverage * 0.96
        }
        else if courseIndexes.count == 17 {
            // Retrieve the lowest 7
            var handicapSum = 0.0
            for i in 0...7 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 7.0
            handicapIndex = handicapAverage * 0.96
        }
        else if courseIndexes.count == 18 {
            // Retrieve the lowest 8
            var handicapSum = 0.0
            for i in 0...8 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 8.0
            handicapIndex = handicapAverage * 0.96
        }
        else if courseIndexes.count == 19 {
            // Retrieve the lowest 9
            var handicapSum = 0.0
            for i in 0...9 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 9.0
            handicapIndex = handicapAverage * 0.96
        }
        else if courseIndexes.count >= 20 {
            // Retrieve the lowest 10
            var handicapSum = 0.0
            for i in 0...10 {
                handicapSum += courseIndexes[i]
            }
            let handicapAverage = handicapSum / 10.0
            handicapIndex = handicapAverage * 0.96
        }
        
        // If male and the index is greater than 36.4 on 18 hole course then reset to the max
        if (handicapIndex > 36.4 && !isNineHoleCourse) {
            handicapIndex = 36.4
        }
        // else if male and the index is greater than 18.2 on 9 hole course then reset to the max
        else if (handicapIndex > 18.2 && isNineHoleCourse) {
            handicapIndex = 18.2
        }
        // else if female and the index is greater than 40.4 on 18 hole course then reset to the max
        // ele if femal and the index is greater than 20.2 on 9 hole course then reset to the max
        
        return Double(indexFormatter.string(for: handicapIndex)!)!
    }
}
