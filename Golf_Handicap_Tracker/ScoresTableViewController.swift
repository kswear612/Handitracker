//
//  ScoresTableViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 12/26/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log

class ScoresTableViewController: UITableViewController {

    //MARK: Properties
    @IBOutlet weak var open: UIBarButtonItem!
    var scores = [Score]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Makes the hamburger menu reveal
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        // Recognize right swipe gesture
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Load any saved courses, otherwise load sample data
        if let savedScores = loadScores() {
            scores += savedScores
        }
        else {
            // Load the sample data
            loadSampleScores()
        }
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
        return scores.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ScoresTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ScoresTableViewCell else {
            fatalError("The dequeued cell is not an instance of ScoreTableViewCell")
        }

        // Fetches the appropriate course for the data source layout
        let score = scores[indexPath.row]
        
        cell.scoreLabel.text = String(score.score)
        cell.courseNameLabel.text = score.courseName
        
        // format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        cell.dateLabel.text = dateFormatter.string(from: score.date)

        return cell
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

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            scores.remove(at: indexPath.row)
            saveScores()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
            os_log("Adding a new score", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let scoreDetailViewController = segue.destination as? ScoresViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedScoreCell = sender as? ScoresTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedScoreCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedScore = scores[indexPath.row]
            scoreDetailViewController.score = selectedScore
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToScoreList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ScoresViewController, let score = sourceViewController.score {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing course
                scores[selectedIndexPath.row] = score
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new course
                let newIndexPath = IndexPath(row: scores.count, section: 0)
                scores.append(score)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the courses
            saveScores()
        }
    }
    
    @IBAction func unwindToScoreListFromCancel(sender: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    private func loadSampleScores() {
        guard let score1 = Score(score: 90, courseName: "Pebble Beach", date: Date()) else {
            fatalError("Unable to instantiate Pebble Beach score")
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 11
        dateComponents.day = 10
        guard let score2 = Score(score: 95, courseName: "Bethpage Black", date: Calendar.current.date(from: dateComponents)!) else {
            fatalError("Unable to instantiate Bethpage Black score")
        }
        
        dateComponents.year = 2017
        dateComponents.month = 3
        dateComponents.day = 22
        guard let score3 = Score(score: 72, courseName: "Masters", date: Calendar.current.date(from: dateComponents)!) else {
            fatalError("Unable to instantiate Masters score")
        }
        
        scores += [score1, score2, score3]
    }
    
    private func saveScores() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scores, toFile: Score.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Scores successfully saved", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save scores...", log: OSLog.default, type: .debug)
        }
    }

    private func loadScores() -> [Score]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Score.ArchiveURL.path) as? [Score]
    }
}
