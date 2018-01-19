//
//  AboutMe.swift
//  Golf_Handicap_Tracker
//
//  Created by Kyle Swearingen on 1/11/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import Foundation
import os.log

class AboutMe: NSObject, NSCoding {
    
    //MARK: Properties
    var firstName: String
    var lastName: String
    var gender: String
    var age: String
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("aboutMe")
    
    //MARK: Types
    struct PropertyKey {
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let gender = "gender"
        static let age = "age"
    }
    
    //MARK: Initilization
    init?(firstName: String, lastName: String, gender: String, age: String) {
        // The first name must not be empty
        guard !firstName.isEmpty else {
            return nil
        }
        
        // The last name must not be empty
        guard !lastName.isEmpty else {
            return nil
        }
        
        // The gender must not be empty
        guard !gender.isEmpty else {
            return nil
        }
        
        // The age must not be empty
        guard !age.isEmpty else {
            return nil
        }
        
        self.firstName  = firstName
        self.lastName = lastName
        self.gender = gender
        self.age = age
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(firstName, forKey: PropertyKey.firstName)
        aCoder.encode(lastName, forKey: PropertyKey.lastName)
        aCoder.encode(gender, forKey: PropertyKey.gender)
        aCoder.encode(age, forKey: PropertyKey.age)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The firstName is required. If we cannot decode a firstName string, the initializer should fail
        guard let firstName = aDecoder.decodeObject(forKey: PropertyKey.firstName) as? String else {
            os_log("Unable to decode the first name for a About Me object", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The lastName is required. If we cannot decode a lastName string, the initializer should fail
        guard let lastName = aDecoder.decodeObject(forKey: PropertyKey.lastName) as? String else {
            os_log("Unable to decode the last name for a About Me object", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The gender is required. If we cannot decode a gender string, the initializer should fail
        guard let gender = aDecoder.decodeObject(forKey: PropertyKey.gender) as? String else {
            os_log("Unable to decode the gender for a About Me object", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The age is required. If we cannot decode a age string, the initializer should fail
        guard let age = aDecoder.decodeObject(forKey: PropertyKey.age) as? String else {
            os_log("Unable to decode the age for a About Me object", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(firstName: firstName, lastName: lastName, gender: gender, age: age)
    }
}
