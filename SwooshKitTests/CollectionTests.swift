//
//  SwooshKitTests.swift
//  SwooshKitTests
//
//  Created by Airspeed Velocity on 11/27/14.
//  Copyright (c) 2014 Airspeed Velocity. All rights reserved.
//

import SwooshKit
import XCTest

class SwooshKitTests: XCTestCase {
    
    let strToInt = { (s: String)->Int? in s.toInt() }
    let intToStr = { (i: Int)->String in "\(i)" }

    func testMapSome() {
        XCTAssert(equal([1,2,3], mapSome(["1","2","3"], strToInt)))
        XCTAssert(equal([1,2,3], mapSome(["1", "blah","2","3"], strToInt)))
        XCTAssert(equal([] as [Int], mapSome([] as [String], strToInt)))
        
        XCTAssert(equal([1,2,3], mapSome(["1","2","3"], strToInt) as ContiguousArray))
        XCTAssert(equal([1,2,3], mapSome(["1", "blah","2","3"], strToInt) as ContiguousArray))

// These currently crash Xcode but shouldn't
//        XCTAssert(equal(["1","2","3"], mapSome([1,2,3], intToStr)))
//        XCTAssert(equal(["1","2","3"], mapSome(1...3, intToStr)))
    }
    
    func testLazyMapSome() {
        XCTAssert(equal([1,2,3], mapSome(lazy(["1","2","3"]), strToInt)))
        XCTAssert(equal([1,2,3], mapSome(lazy(["1", "blah","2","3"]), strToInt)))
        XCTAssert(equal([] as [Int], mapSome(lazy([] as [String]), strToInt)))
    }
    
    func testAccumulate() {
        
        let inital = 0
        let array = [1,2,3]
        let someInts = ["1","2","blah","3"]
        
        let expected = [0,1,3,6]
        
        XCTAssert(equal([0,1,3,6], accumulate([1,2,3], 0, +)))
        XCTAssert(equal([0], accumulate([], 0, +)))
    }
    
    func testLuhnAlgo() {
        // happens to use several of the functions in this library so good to detect weird type inference issues
        
        let extractDigits = { (s: String)->[Int] in mapSome(s, toInt) }
        let combineDoubleDigit = { i in i < 10 ? i : i-9 }
        let doubleEveryOther = { (ints: [Int])->[Int] in mapEveryNth(ints, 2, combineDoubleDigit • double) }
        
        let checksum = isMultipleOf(10) • sum • doubleEveryOther • reverse • extractDigits

        let ccnum = "4012 8888 8888 1881"

    }
    
}
