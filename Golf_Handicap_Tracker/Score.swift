//
//  Score.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/2/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Score: NSObject, NSCoding {

    //MARK: Properties
    var score: Int
    var courseName: String
    var date: Date
    var scorecardPhoto: UIImage?
    var scoreIdentifier: String
    var courseIdentifier: String
    var holes: [Hole]
    //var scoreDetail: ScoreDetail?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("scores")
    
    //MARK: Types
    struct PropertyKey {
        static let score = "score"
        static let courseName = "courseName"
        static let date = "date"
        static let scorecardPhoto = "scorecardPhoto"
        static let scoreIdentifier = "scoreIdentifier"
        static let courseIdentifier = "courseIdentifier"
        static let holes = "holes"
    }
    
    //MARK:Initialization
    init?(score: Int, courseName: String, date: Date, scorecardPhoto: UIImage?, scoreIdentifier: String, courseIdentifier: String, holes: [Hole]) {
        // The score must be greater than 0
        guard score > 0 else {
            return nil
        }
        
        // The course name cannot be empty
        guard !courseName.isEmpty else {
            return nil
        }
        
        // The score identifier cannot be empty
        guard !scoreIdentifier.isEmpty else {
            return nil
        }
        
        // The score identifier cannot be empty
        guard !courseIdentifier.isEmpty else {
            return nil
        }

        self.score = score
        self.courseName = courseName
        self.date = date
        self.scorecardPhoto = scorecardPhoto
        self.scoreIdentifier = scoreIdentifier
        self.courseIdentifier = courseIdentifier
        //self.scoreDetail = scoreDetail
        self.holes = holes
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(score, forKey: PropertyKey.score)
        aCoder.encode(courseName, forKey: PropertyKey.courseName)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(scorecardPhoto, forKey: PropertyKey.scorecardPhoto)
        aCoder.encode(scoreIdentifier, forKey: PropertyKey.scoreIdentifier)
        aCoder.encode(courseIdentifier, forKey: PropertyKey.courseIdentifier)
        aCoder.encode(holes, forKey: PropertyKey.holes)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let score = aDecoder.decodeInteger(forKey: PropertyKey.score)
        let courseName = aDecoder.decodeObject(forKey: PropertyKey.courseName) as! String
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as! Date
        let scorecardPhoto = aDecoder.decodeObject(forKey: PropertyKey.scorecardPhoto) as? UIImage
        
        // The scoreIdentifier is required. If we cannot decode a scoreIdentifier string, the initializer should fail
        guard let scoreIdentifier = aDecoder.decodeObject(forKey: PropertyKey.scoreIdentifier) as? String else {
            os_log("Unable to decode the score identifier for a Score object", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The courseIdentifier is required. If we cannot decode a courseIdentifier string, the initializer should fail
        guard let courseIdentifier = aDecoder.decodeObject(forKey: PropertyKey.courseIdentifier) as? String else {
            os_log("Unable to decode the course identifier for a Score object", log: OSLog.default, type: .debug)
            return nil
        }
        
        let holes = aDecoder.decodeObject(forKey: PropertyKey.holes) as? [Hole]
        
        self.init(score: score, courseName: courseName, date: date, scorecardPhoto: scorecardPhoto, scoreIdentifier: scoreIdentifier, courseIdentifier: courseIdentifier, holes: holes!)
    }
}
