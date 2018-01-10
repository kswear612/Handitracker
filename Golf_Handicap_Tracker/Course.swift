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
    var courseSlope: Int
    var isNineHoleCourse: Bool
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("courses")
    
    //MARK: Types
    struct PropertyKey {
        static let courseName = "courseName"
        static let photo = "photo"
        static let courseRating = "courseRating"
        static let courseSlope = "courseSlope"
        static let isNineHoleCourse = "isNineHoleCourse"
    }
    
    //MARK: Initialization
    init?(courseName: String, photo: UIImage?, courseRating: Double, courseSlope: Int, isNineHoleCourse: Bool) {
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
        self.isNineHoleCourse = isNineHoleCourse
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(courseName, forKey: PropertyKey.courseName)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(courseRating, forKey: PropertyKey.courseRating)
        aCoder.encode(courseSlope, forKey: PropertyKey.courseSlope)
        aCoder.encode(isNineHoleCourse, forKey: PropertyKey.isNineHoleCourse)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The courseName is required. If we cannot decode a courseName string, the initializer should fail
        guard let courseName = aDecoder.decodeObject(forKey: PropertyKey.courseName) as? String else {
            os_log("Unable to decode the course name for a Course object", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Course, just used conditional cast
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let courseRating = aDecoder.decodeDouble(forKey: PropertyKey.courseRating)
        let courseSlope = aDecoder.decodeInteger(forKey: PropertyKey.courseSlope)
        let isNineHoleCourse = aDecoder.decodeBool(forKey: PropertyKey.isNineHoleCourse)
        
        self.init(courseName: courseName, photo: photo, courseRating: courseRating, courseSlope: courseSlope, isNineHoleCourse: isNineHoleCourse)
    }
    
    
}
