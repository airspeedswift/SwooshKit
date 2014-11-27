//
//  SwooshKitTests.swift
//  SwooshKitTests
//
//  Created by Ben Cohen on 11/27/14.
//  Copyright (c) 2014 Airspeed Velocity. All rights reserved.
//

import SwooshKit
import XCTest

class SwooshKitTests: XCTestCase {

    func testMapSome() {
        let strToInt = { (s: String)->Int? in s.toInt() }
        let intToStr = { (i: Int)->String in "\(i)" }
        
        XCTAssert(equal([1,2,3], mapSome(["1","2","3"], strToInt)))
        XCTAssert(equal([1,2,3], mapSome(["1", "blah","2","3"], strToInt)))
        XCTAssert(equal([] as [Int], mapSome([] as [String], strToInt)))
        
        XCTAssert(equal([1,2,3], mapSome(["1","2","3"], strToInt) as ContiguousArray))
        XCTAssert(equal([1,2,3], mapSome(["1", "blah","2","3"], strToInt) as ContiguousArray))

// These currently crash Xcode but shouldn't
//        XCTAssert(equal(["1","2","3"], mapSome([1,2,3], intToStr)))
//        XCTAssert(equal(["1","2","3"], mapSome(1...3, intToStr)))
    }
    
    func testAccumulate() {
        
        let inital = 0
        let array = [1,2,3]
        let someInts = ["1","2","blah","3"]
        
        let expected = [0,1,3,6]
        
        XCTAssert(equal([0,1,3,6], accumulate([1,2,3], 0, +)))
        XCTAssert(equal([0], accumulate([], 0, +)))
    }
}
