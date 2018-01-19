//
//  Golf_Handicap_TrackerTests.swift
//  Golf_Handicap_TrackerTests
//
//  Created by Kyle Swearingen on 1/15/18.
//  Copyright © 2018 Kyle Swearingen. All rights reserved.
//

import XCTest
@testable import Golf_Handicap_Tracker

class Golf_Handicap_TrackerTests: XCTestCase {
    
    //MARK: Course Class Tests
    func testCourseInitializationSucceeds() {
        // Zero course rating & slope
        let zeroCourseRatingAndSlope = Course.init(courseName: "Test", photo: nil, courseRating: 1.0, courseSlope: 1, isNineHoleCourse: false)
        XCTAssertNotNil(zeroCourseRatingAndSlope)
    }
    
    func testCourseInitializationFails() {
        // No course name
        let noCourseName = Course.init(courseName: "", photo: nil, courseRating: 1.0, courseSlope: 1, isNineHoleCourse: false)
        XCTAssertNil(noCourseName)
        
        // Zero course rating
        let zeroCourseRating = Course.init(courseName: "Test", photo: nil, courseRating: 0, courseSlope: 1, isNineHoleCourse: false)
        XCTAssertNil(zeroCourseRating)
        
        // Zero course slope
        let zeroCourseSlope = Course.init(courseName: "Test", photo: nil, courseRating: 1.0, courseSlope: 0, isNineHoleCourse: false)
        XCTAssertNil(zeroCourseSlope)
    }
    
    //MARK: Score Class Tests
    func testScoreInitializationSucceeds() {
        //Everything filled in
        let everythingFilledIn = Score.init(score: 1, courseName: "Test", date: Date(), scorecardPhoto: nil)
        XCTAssertNotNil(everythingFilledIn)
    }
    
    func testScoreInitializationFails() {
        // No course name
        let noCourseName = Score.init(score: 1, courseName: "", date: Date(), scorecardPhoto: nil)
        XCTAssertNil(noCourseName)
        
        // Zero score
        let zeroScore = Score.init(score: 0, courseName: "Test", date: Date(), scorecardPhoto: nil)
        XCTAssertNil(zeroScore)
        
        // Negative score
        let negativeScore = Score.init(score: -1, courseName: "Test", date: Date(), scorecardPhoto: nil)
        XCTAssertNil(negativeScore)
    }
}
