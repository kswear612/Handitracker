//
//  Course.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 12/26/17.
//  Copyright © 2017 Kyle Swearingen. All rights reserved.
//

import Foundation
import os.log

class Course: NSObject, NSCoding {
    
    //MARK: Properties
    var courseName: String
    var photo: UIImage?
    var courseRating: Double
    var courseSlope: Double
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("courses")
    
    //MARK: Types
    struct PropertyKey {
        static let courseName = "courseName"
        static let photo = "photo"
        static let courseRating = "courseRating"
        static let courseSlope = "courseSlope"
    }
    
    //MARK: Initialization
    init?(courseName: String, photo: UIImage?, courseRating: Double, courseSlope: Double) {
        // The course name must not be empty
        guard !courseName.isEmpty else {
            return nil
        }
        
        // The course rating must be > 0
        guard courseRating > 0 else {
            return nil
        }
        
        // The course slope must be > 0
        guard courseSlope > 0 else {
            return nil
        }
        
        self.courseName = courseName
        self.photo = photo
        self.courseRating = courseRating
        self.courseSlope = courseSlope
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(courseName, forKey: PropertyKey.courseName)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(courseRating, forKey: PropertyKey.courseRating)
        aCoder.encode(courseSlope, forKey: PropertyKey.courseSlope)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The courseName is required. If we cannot decode a courseName string, the initializer should fail
        guard let courseName = aDecoder.decodeObject(forKey: PropertyKey.courseName) as? String else {
            os_log("Unable to decode the course name for a Course object", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Course, just used conditional cast
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        // The courseRating is required. If we cannot decode a courseRating double, the initializer should fail
        guard let courseRating = aDecoder.decodeObject(forKey: PropertyKey.courseRating) as? Double else {
            os_log("Unable to decode the course rating for a Course object", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The courseSlope is required. If we cannot decode a courseSlope double, the initializer should fail
        guard let courseSlope = aDecoder.decodeObject(forKey: PropertyKey.courseSlope) as? Double else {
            os_log("Unable to decode the course slope for a Course object", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(courseName: courseName, photo: photo, courseRating: courseRating, courseSlope: courseSlope)
    }
    
    
}
