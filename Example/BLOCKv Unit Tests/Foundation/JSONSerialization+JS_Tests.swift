//
//  JSONSerialization+JS_Tests.swift
//  BLOCKv_Unit_Tests
//
//  Created by Cameron McOnie on 2018/11/06.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import BLOCKv

class JSONSerialization_JS_Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let someString = "hello"
        
        let someObject1: Any = ["key": "hello"]
        
        do {
            let a = try JSONSerialization.data(withJSONObject: someObject1, options: .prettyPrinted)
            print(a)
            let aa = JSONSerialization.javascriptString(withJSONObject: someObject1)
            print(aa)
            
            let b = JSONSerialization.javascriptString(withJSONObject: someString)
            print(b)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }

}
