//
//  Hole.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/22/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import Foundation
import os.log

class Hole : NSObject, NSCoding {
    
    //MARK: Properties
    var holeNumber: Int
    var holeStrokes: Int
    //var scoreIdentifier: String
    
    //MARK: Types
    struct PropertyKey {
        static let holeNumber = "holeNumber"
        static let holeStrokes = "holeStrokes"
        //static let scoreIdentifier = "scoreIdentifier"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("holes")
    
    //MARK: Initialization
    init?(holeNumber: Int, holeStrokes:Int) {
        // Hole number has to be greater than 0
        guard holeNumber > 0 else {
            return nil
        }
        
        // Hole number must not exceed 18
        guard holeNumber <= 18 else {
            return nil
        }
        
        // Hole strokes has to be greater than 0
        guard holeStrokes >= 0 else {
            return nil
        }
        
        self.holeNumber = holeNumber
        self.holeStrokes = holeStrokes
        //self.scoreIdentifier = scoreIdentifier
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(holeNumber, forKey: PropertyKey.holeNumber)
        aCoder.encode(holeStrokes, forKey: PropertyKey.holeStrokes)
        //aCoder.encode(scoreIdentifier, forKey: PropertyKey.scoreIdentifier)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let holeNumber = aDecoder.decodeInteger(forKey: PropertyKey.holeNumber)
        let holeStrokes = aDecoder.decodeInteger(forKey: PropertyKey.holeStrokes)
        
        // The score identifier is required. If we cannot decode a score identifier integer, the initializer should fail
        /*guard let scoreIdentifier = aDecoder.decodeObject(forKey: PropertyKey.scoreIdentifier) as? String else {
            os_log("Unable to decode the score identifier for score detail", log: OSLog.default, type: .debug)
            return nil
        }*/
        
        self.init(holeNumber: holeNumber, holeStrokes: holeStrokes)
    }
}
