//
//  SwooshKitTests.swift
//  SwooshKitTests
//
//  Created by Airspeed Velocity on 11/27/14.
//  Copyright (c) 2014 Airspeed Velocity. All rights reserved.
//

import SwooshKit
import XCTest

class SwooshKitFunctionTests: XCTestCase {
    
    func testFreeMemberFunc() {
        let toInt = freeMemberFunc(String.toInt)
        
        XCTAssertNil(toInt("blah"))
        XCTAssertNotNil(toInt("1"))
        XCTAssertEqual(toInt("1")!, 1)
    }
    
    func testToInt() {
        XCTAssertNil(toInt("blah"))
        XCTAssertNotNil(toInt("1"))
        XCTAssertEqual(toInt("1")!, 1)
    }
    
    func testDouble() {
        XCTAssertEqual(double(2 as Int), 4 as Int)
        XCTAssertEqual(double(2) as Int16, 4 as Int16)
    }
    
    func testSum() {
        let ints: [UInt8] = [1,2,3]
        XCTAssertEqual(sum(ints), 6 as UInt8)
    }
    
}
