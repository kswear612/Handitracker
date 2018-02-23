//
//  ScoreDetailViewController.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/22/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import UIKit
import os.log

class ScoreDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet var scoreDetailTableView: UITableView!
    var score: Score?
    var holes = [Hole]()
    var scoreIdentifier = ""
    var courseIdentifier = ""
    var sliderValuesArray = [Float](repeating: 0.0, count: 18)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreDetailTableView.delegate = self
        scoreDetailTableView.dataSource = self
        
        /*if score != nil, let savedScoreDetail = score?.scoreDetail {
         holes = savedScoreDetail.holes
         if (holes.count == 18) {
         for hole in holes {
         sliderValuesArray[hole.holeNumber-1] = Float(hole.holeStrokes)
         }
         }
         else {
         for i in 1...18 {
         holes.append(Hole(holeNumber: i, holeStrokes: 0)!)
         }
         score?.scoreDetail?.holes = holes
         score?.scoreDetail?.roundTotal = 0
         }
         }
         else {
         fatalError("Score did not get passed into the detail")
         }*/
        holes = (score?.holes)!
        if (holes.count == 18) {
            for hole in holes {
                sliderValuesArray[hole.holeNumber-1] = Float(hole.holeStrokes)
            }
        }
        else {
            for i in 1...18 {
                holes.append(Hole(holeNumber: i, holeStrokes: 0)!)
            }
            score?.holes = holes
        }
    }
    
    //MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return enough rows for entire round
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ScoreDetailTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ScoreDetailTableViewCell else {
            fatalError("The dequeed cell is not an instance of ScoreDetailTableViewCell")
        }
        
        let hole = holes[indexPath.row]
        
        cell.holeStrokesSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        cell.holeStrokesSlider.tag = indexPath.row
        cell.holeNumberLabel.text = "#" + String(hole.holeNumber)
        cell.holeStrokesLabel.text = String(Int(sliderValuesArray[indexPath.row]))
        cell.holeStrokesSlider.value = Float(sliderValuesArray[indexPath.row])
        
        return cell
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let courseName = score?.courseName
        let scoreValue = score?.score
        let date = score?.date
        let photo = score?.scorecardPhoto
        var holes = [Hole]()
        var roundTotal = 0
        for i in 0..<sliderValuesArray.count {
            holes.append(Hole(holeNumber: i+1, holeStrokes: Int(sliderValuesArray[i]))!)
            roundTotal += Int(sliderValuesArray[i])
        }
        //let scoreDetail = ScoreDetail(holes: holes, roundTotal: roundTotal, courseIdentifier: (score?.courseIdentifier)!, scoreIdentifier: (score?.scoreIdentifier)!)
        
        // Set the score to be passed to the ScoreTableViewController after the unwind segue
        score = Score(score: scoreValue!, courseName: courseName!, date: date!, scorecardPhoto: photo, scoreIdentifier: (score?.scoreIdentifier)!, courseIdentifier: (score?.courseIdentifier)!, holes: holes)
    }
    
    //MARK: Private Methods
    @objc func sliderValueChanged(sender: UISlider) {
        sliderValuesArray[sender.tag] = sender.value
    }
    
}

