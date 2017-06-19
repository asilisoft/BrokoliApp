//
//  BrokoliTests.swift
//  BrokoliTests
//
//  Created by Sergi Ranís i Nebot on 16/6/17.
//  Copyright © 2017 Asilisoft. All rights reserved.
//

import XCTest
@testable import Brokoli


class BrokoliTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    

    func testUIColorExtensions() {
        var color = UIColor(hexString: "f00")
        XCTAssertEqual(color, UIColor.red)
        
        color = UIColor(hexString: "cadena erronea")
        XCTAssertEqual(color, UIColor(red: 0, green: 0, blue: 0, alpha: 1.0))
    }

    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
