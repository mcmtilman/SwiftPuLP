////
//  PerformanceTests.swift
//  
//  Created by Michel Tilman on 08/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

#if !DEBUG

import XCTest
import PythonKit
import SwiftPuLP

final class PerformanceTests: XCTestCase {
    
    // MARK: Linear function tests
    
    func testBuildFunction() {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        let parameters = ["x": 1.0, "y": 2.0, "z": 3]

        measure {
            var function = LinearFunction()

            for _ in 1...1000000 {
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
        
            for _ in 1...1000000 {
                sum += function(parameters)
            }
            
            if sum != 0 { return XCTFail("Invalid sum")}
        }
    }
    
}

#endif
