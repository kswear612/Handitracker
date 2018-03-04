//
//  ScoresTableViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 12/26/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log

class ScoresTableViewController: UITableViewController, UISearchResultsUpdating {
    
    //MARK: Properties
    @IBOutlet weak var open: UIBarButtonItem!
    var scores = [Score]()
    var filteredScores = [Score]()
    let searchController = UISearchController(searchResultsController: nil)
    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.clearDiskCache()
        
        // Recognize right swipe gesture
        //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by course name"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Load any saved scores
        if let savedScores = loadScores() {
            scores += savedScores
        }
        
        filteredScores = scores
        
        if (!searchString.isEmpty) {
            searchController.searchBar.text = searchString
            updateSearchResults(for: searchController)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scores = [Score]()
        
        // Load any saved scores
        if let savedScores = loadScores() {
            scores += savedScores
        }
        
        filteredScores = scores
        
        if (!searchString.isEmpty) {
            searchController.searchBar.text = searchString
            updateSearchResults(for: searchController)
        }
        
        self.tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows that will be shown in the table
        return filteredScores.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ScoresTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ScoresTableViewCell else {
            fatalError("The dequeued cell is not an instance of ScoreTableViewCell")
        }
        
        // Fetches the appropriate course for the data source layout
        let score = filteredScores[indexPath.row]
        
        cell.scoreLabel.text = String(score.score)
        cell.courseNameLabel.text = score.courseName
        
        // format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        cell.dateLabel.text = dateFormatter.string(from: score.date)
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredScores = scores
        }
        else {
            filteredScores = scores.filter({$0.courseName.lowercased().contains(searchController.searchBar.text!.lowercased())})
        }
        self.tableView.reloadData()
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
            filteredScores.remove(at: indexPath.row)
            saveScores()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addScoreDetail = UITableViewRowAction(style: .normal, title: "View Score Detail") { action, indexPath in
            self.performSegue(withIdentifier: "ViewScoreDetail", sender: tableView.cellForRow(at: indexPath))
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            // Determine if the grid is filtered or not
            if self.filteredScores[indexPath.row].scoreIdentifier != self.scores[indexPath.row].scoreIdentifier {
                // Find the corresponding score in the main array and remove it
                var counter = 0
                for selectedScore in self.scores {
                    if self.filteredScores[indexPath.row].scoreIdentifier == selectedScore.scoreIdentifier {
                        self.scores.remove(at: counter)
                    }
                    counter += 1
                }
                
                // Now delete the record from the filtered list
                self.filteredScores.remove(at: indexPath.row)
            }
            else {
                self.scores.remove(at: indexPath.row)
                self.filteredScores.remove(at: indexPath.row)
            }
            
            self.saveScores()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        addScoreDetail.backgroundColor = UIColor.init(red: 3/255, green: 121/255, blue: 0/255, alpha: 1.0)
        
        return [delete, addScoreDetail]
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddScore":
            os_log("Adding a new score", log: OSLog.default, type: .debug)
        case "ViewScoreDetail":
            guard let scoreDetailViewController = segue.destination as? ScoreDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let cellViewController = sender as? ScoresTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: cellViewController) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let scoreIdentifier = filteredScores[indexPath.row].scoreIdentifier
            let courseIdentifier = filteredScores[indexPath.row].courseIdentifier
            scoreDetailViewController.scoreIdentifier = scoreIdentifier
            scoreDetailViewController.courseIdentifier = courseIdentifier
            if scores[indexPath.row].holes.isEmpty {
                var holes = [Hole]()
                for i in 1...18 {
                    holes.append(Hole(holeNumber: i, holeStrokes: 0)!)
                }
                //scores[indexPath.row].scoreDetail = ScoreDetail(holes: holes, roundTotal: 0, courseIdentifier: courseIdentifier, scoreIdentifier: scoreIdentifier)!
                scores[indexPath.row].holes = holes
            }
            scoreDetailViewController.score = filteredScores[indexPath.row]
            os_log("Adding score detail", log: OSLog.default, type: .debug)
        case "ScoreDetail":
            guard let scoreDetailViewController = segue.destination as? ScoresViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedScoreCell = sender as? ScoresTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedScoreCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedScore = filteredScores[indexPath.row]
            scoreDetailViewController.score = selectedScore
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindFromScoreSave(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ScoresViewController, let score = sourceViewController.score {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Check to see if the record we are updating is filtered
                if filteredScores[selectedIndexPath.row].scoreIdentifier == score.scoreIdentifier {
                    // find the array position of the score in the main array
                    var counter = 0
                    for selectedScore in scores {
                        if selectedScore.scoreIdentifier == score.scoreIdentifier {
                            scores[counter] = score
                        }
                        counter += 1
                    }
                    // Update the filtered list
                    filteredScores[selectedIndexPath.row] = score
                }
                // Scores aren't filtered so update both arrays in the same spot
                else {
                    // Update an existing score
                    scores[selectedIndexPath.row] = score
                    filteredScores[selectedIndexPath.row] = score
                }
                
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new score
                let newIndexPath = IndexPath(row: scores.count, section: 0)
                scores.append(score)
                filteredScores.append(score)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the scores
            saveScores()
        }
        // If we are saving the score detail for a score we need to handle it here
        else if let sourceViewController = sender.source as? ScoreDetailViewController, let score = sourceViewController.score {
            // Need to loop through the filtered scores first because it is possible that array is smaller because the courses are filtered
            for i in 0..<filteredScores.count {
                for j in 0..<scores.count {
                    if filteredScores[i].scoreIdentifier == score.scoreIdentifier  && filteredScores[i].scoreIdentifier == scores[j].scoreIdentifier {
                        // Add the detail to the existing score
                        scores[j] = score
                        filteredScores[i] = score
                        let selectedIndexPath = IndexPath(row: i, section: 0)
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                        break;
                    }
                }
            }
            
            saveScores()
        }
    }
    
    @IBAction func unwindFromScoreCancel(sender: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
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
    
    func clearDiskCache() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diskCacheStorageBaseUrl = myDocuments.appendingPathComponent("scores")
        guard let filePaths = try? fileManager.contentsOfDirectory(at: diskCacheStorageBaseUrl, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }
}

