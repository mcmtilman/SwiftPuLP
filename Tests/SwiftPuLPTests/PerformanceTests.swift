//
//  PerformanceTests.swift
//  
//  Created by Michel Tilman on 08/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import SwiftPuLP

final class PerformanceTests: XCTestCase {
    
    // MARK: Linear function tests
    
#if DEBUG
    let iterations = 10000
    
    override func measure(_ block: () -> Void) {
        block()
    }
#else
    let iterations = 100000
#endif

    func testBuildFunction() {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        let parameters = ["x": 1.0, "y": 2.0, "z": 3]

        measure {
            var function = LinearFunction()

            for _ in 1...iterations {
                function = x + y - z
            }
            
            if function(parameters) != 0 { return XCTFail("Invalid function call" )}
        }
    }
    
    func testFunctionCall() {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        let function = x + y - z
        let parameters = ["x": 1.0, "y": 2.0, "z": 3]
        
        measure {
            var sum = 0.0
        
            for _ in 1...iterations {
                sum += function(parameters)
            }
            
            if sum != 0 { return XCTFail("Invalid sum")}
        }
    }
    
    func testNormalizedFunction() {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        let function = x + 2 * y - z - x
        var f = function
        
        measure {
            for _ in 1...iterations {
               f = function.normalized()
            }
        }
        
        XCTAssertEqual(f, 2 * y - z)
    }
    
}
