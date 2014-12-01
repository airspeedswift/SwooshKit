//
//  SwooshKitTests.swift
//  SwooshKitTests
//
//  Created by Airspeed Velocity on 11/27/14.
//  Copyright (c) 2014 Airspeed Velocity. All rights reserved.
//

import SwooshKit
import XCTest

class SwooshKitCollectionTests: XCTestCase {
    
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
        
        let lms = mapSome(lazy("12345"), toInt)
        XCTAssertEqual("Swift.LazySequence",reflect(lms).summary)
        
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
    
    func testRemove() {
        let isVowel = { contains("eaoiu", $0) }
        var s = Array("hello")
        remove(&s, "e" as Character)
        XCTAssertEqual("hllo", String(s))
        s = Array("hello")
        remove(&s, isVowel)
        XCTAssertEqual("hll", String(s))
    }
    
    func testFind() {
        let s = "hello"
        let idx = find(s,isVowel)
        XCTAssert(idx != nil)
        XCTAssertEqual(s.startIndex.successor(), find(s,isVowel)!)
    }
    
    func testEqual() {
        let eqIntString: (Int,String)->Bool = { i,s in s.toInt().map { $0 == i } ?? false }
        
        XCTAssertTrue(equal([1,2,3], ["1","2","3"], eqIntString))
        XCTAssertTrue(equal(1...3, ["1","2","3"], eqIntString))
        XCTAssertTrue(equal([Int](),[String](), eqIntString))
        XCTAssertFalse(equal([1,2,3,4], ["1","2","3"], eqIntString))
        XCTAssertFalse(equal([1,2,3], ["1","2","3","4"], eqIntString))
        XCTAssertFalse(equal([1,1,3], ["1","2","3"], eqIntString))
        XCTAssertFalse(equal([1,2,3], ["1","3","3"], eqIntString))
    }
    
    func testLuhnAlgo() {
        // happens to use several of the functions in this library so good to
        // detect weird type inference issues
        
        let extractDigits: String -> [Int] = { mapSome($0, toInt) }
        
        let doubleAndCombine = { i in i<5 ? i*2 : i*2-9 }
        
        let doubleEveryOther: [Int]->[Int] = { mapEveryNth($0, 2, doubleAndCombine) }
        
        let checksum = isMultipleOf(10) • sum • doubleEveryOther • reverse • extractDigits
        
        let ccnum = "4012 8888 8888 1881"
        
        XCTAssert(checksum(ccnum))
        XCTAssertFalse(checksum(dropFirst(ccnum)))

        let is_ok: Bool =
        ccnum
            |> { mapSome($0, toInt) }
            |> reverse
            |> { mapEveryNth($0, 2, doubleAndCombine) }
            |> sum
            |> isMultipleOf(10)
        
        XCTAssert(is_ok)
    }
    
    func testLazyLuhnAlgo() {
        let doubleAndCombine = { i in i<5 ? i*2 : i*2-9 }
        
        // TODO: a way to check this is lazy all the way through
        // and not falling back to the eager versions

        let lazy_checksum: String -> Bool =
              isMultipleOf(10)
            • sum
            • { mapEveryNth($0, 2, doubleAndCombine) }
            // TODO: figure out why the `as` is needed here
            • { mapSome($0, toInt as Character->Int?) }
            • reverse
            • lazy
        
        let ccnum = "4012 8888 8888 1881"
        
        XCTAssert(lazy_checksum(ccnum))
        
        let is_ok =
            ccnum
            |> lazy
            |> reverse
            |> { mapSome($0, toInt as Character->Int?) }
            |> { mapEveryNth($0, 2, doubleAndCombine) }
            |> sum
            |> isMultipleOf(10)
        
        XCTAssert(is_ok)
    }
    
    func testDropFirst() {
        XCTAssert(equal([2,3,4],dropFirst(stride(from: 1, to: 5, by: 1))))
        XCTAssert(equal([],dropFirst(stride(from: 1, to: 2, by: 1))))
        XCTAssert(equal([],dropFirst(stride(from: 1, to: 1, by: 1))))
    }
}
