//
//  BlockV AG. Copyright (c) 2018, all rights reserved.
//
//  Licensed under the BlockV SDK License (the "License"); you may not use this file or
//  the BlockV SDK except in compliance with the License accompanying it. Unless
//  required by applicable law or agreed to in writing, the BlockV SDK distributed under
//  the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
//  ANY KIND, either express or implied. See the License for the specific language
//  governing permissions and limitations under the License.
//

import XCTest
@testable import BLOCKv

class GenericJsonMerge_Tests: XCTestCase {
    
    func testPrimitiveStringType() {
        let A = try! JSON("a")
        let B = try! JSON("b")
        XCTAssertEqual(A.updated(applying: B), B)
    }
    
    func testPrimativeNumberType() {
        let A = try! JSON(123)
        let B = try! JSON(456)
        XCTAssertEqual(A.updated(applying: B), B)
    }
    
    func testMergeEqual() {
        let json = try! JSON(["a": "A"])
        XCTAssertEqual(json.updated(applying: json), json)
    }
    
    func testMergeUnequalValues() {
        let A = try! JSON(["a": "A"])
        let B = try! JSON(["a": "B"])
        XCTAssertEqual(A.updated(applying: B), B)
    }
    
    func testMergeUnequalKeysAndValues() {
        let A = try! JSON(["a": "A"])
        let B = try! JSON(["b": "B"])
        XCTAssertEqual(A.updated(applying: B), try! JSON(["a": "A", "b": "B"]))
    }
    
    func testMergeFilledAndEmpty() {
        let A = try! JSON(["a": "A"])
        let B = try! JSON([:])
        XCTAssertEqual(A.updated(applying: B), A)
    }
    
    func testMergeEmptyAndFilled() {
        let A = try! JSON([:])
        let B = try! JSON(["a": "A"])
        XCTAssertEqual(A.updated(applying: B), B)
    }
    
    func testMergeArray() {
        let A = try! JSON(["a"])
        let B = try! JSON(["b"])
        XCTAssertEqual(A.updated(applying: B), B)
    }
    
    func testMergeNestedJSONs() {
        let A = try! JSON([
            "nested": [
                "a": "A"
            ]
            ])
        
        let B = try! JSON([
            "nested": [
                "a": "B"
            ]
            ])
        
        XCTAssertEqual(A.updated(applying: B), B)
    }
    
    func testMergeNull() {
        
        let A = JSON.null
        let B = JSON.object(["a": "A"])
        XCTAssertEqual(A.updated(applying: B), B)
        
        let C = JSON.object(["a": "A"])
        let D = JSON.null
        XCTAssertEqual(C.updated(applying: D), D)

    }
    
    func testFloat() {
        
//        do {
//            let a = JSON(floatLiteral: 1.333)
//            let b = try JSON([1.333, 2.666, 3.999])
//            
//            print(a)
//            print(b)
//            
//            let ddd = "Hello my old friend".data(using: .utf8)!
//            print(ddd)
//            var we = "adsf".tr
//            let encodedString = String.init(data: ddd, encoding: .utf8)!
//            print(encodedString)
//            
//        } catch {
//            XCTFail(error.localizedDescription)
//        }
        
        
        
    }

}
