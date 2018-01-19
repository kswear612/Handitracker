//
//  Score.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/2/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import Foundation
import os.log

class Score: NSObject, NSCoding {

    //MARK: Properties
    var score: Int
    var courseName: String
    var date: Date
    var scorecardPhoto: UIImage?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("scores")
    
    //MARK: Types
    struct PropertyKey {
        static let score = "score"
        static let courseName = "courseName"
        static let date = "date"
        static let scorecardPhoto = "scorecardPhoto"
    }
    
    //MARK:Initialization
    init?(score: Int, courseName: String, date: Date, scorecardPhoto: UIImage?) {
        // The score must be greater than 0
        guard score > 0 else {
            return nil
        }
        
        // The course name cannot be empty
        guard !courseName.isEmpty else {
            return nil
        }

        self.score = score
        self.courseName = courseName
        self.date = date
        self.scorecardPhoto = scorecardPhoto
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(score, forKey: PropertyKey.score)
        aCoder.encode(courseName, forKey: PropertyKey.courseName)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(scorecardPhoto, forKey: PropertyKey.scorecardPhoto)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let score = aDecoder.decodeInteger(forKey: PropertyKey.score)
        let courseName = aDecoder.decodeObject(forKey: PropertyKey.courseName) as! String
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as! Date
        let scorecardPhoto = aDecoder.decodeObject(forKey: PropertyKey.scorecardPhoto) as? UIImage
        self.init(score: score, courseName: courseName, date: date, scorecardPhoto: scorecardPhoto)
    }
}
