//
//  File.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/22/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import Foundation
import os.log

class ScoreDetail : NSObject, NSCoding {
    
    //MARK: Properties
    var holes: [Hole]
    var roundTotal: Int
    var scoreIdentifier: String
    var courseIdentifier: String
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("scoreDetail")
    
    //MARK: Types
    struct PropertyKey {
        static let holes = "holes"
        static let roundTotal = "roundTotal"
        static let scoreIdentifier = "scoreIdentifier"
        static let courseIdentifier = "courseIdentifier"
    }
    
    //MARK: Initialization
    init?(holes: [Hole], roundTotal: Int, courseIdentifier: String, scoreIdentifier: String) {
        // Holes cannot be empty
        guard !holes.isEmpty else {
            return nil
        }
        
        // Holes array cannot be greater than 18
        guard holes.count <= 18 else {
            return nil
        }
        
        // Round total must be greater than 0
        guard roundTotal >= 0 else {
            return nil
        }
        
        // Course identifier cannot be empty
        guard !courseIdentifier.isEmpty else {
            return nil
        }
        
        // Score identifier cannot be empty
        guard !scoreIdentifier.isEmpty else {
            return nil
        }
        
        self.holes = holes
        self.roundTotal = roundTotal
        self.courseIdentifier = courseIdentifier
        self.scoreIdentifier = scoreIdentifier
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(roundTotal, forKey: PropertyKey.roundTotal)
        aCoder.encode(courseIdentifier, forKey: PropertyKey.courseIdentifier)
        aCoder.encode(scoreIdentifier, forKey: PropertyKey.scoreIdentifier)
        aCoder.encode(holes, forKey: PropertyKey.holes)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The holes array is required. If we cannot decode a holes array,m the initializer should fail
        guard let holes = aDecoder.decodeObject(forKey: PropertyKey.holes) as? [Hole] else {
            os_log("Unable to decode the holes for score detail", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The round total is required. If we cannot decode a round total integer, the initializer should fail
        guard let roundTotal = aDecoder.decodeObject(forKey: PropertyKey.roundTotal) as? Int else {
            os_log("Unable to decode the round total for score detail", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The course identifier is required. If we cannot decode a course identifier string, the initializer should fail
        guard let courseIdentifier = aDecoder.decodeObject(forKey: PropertyKey.courseIdentifier) as? String else {
            os_log("Unable to decode the course identifier for score detail", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The score identifier is required. If we cannot decode a score identifier string, the initializer should fail
        guard let scoreIdentifier = aDecoder.decodeObject(forKey: PropertyKey.scoreIdentifier) as? String else {
            os_log("Unable to decode the score identifier for score detail", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(holes: holes, roundTotal: roundTotal, courseIdentifier: courseIdentifier, scoreIdentifier: scoreIdentifier)
    }
}
