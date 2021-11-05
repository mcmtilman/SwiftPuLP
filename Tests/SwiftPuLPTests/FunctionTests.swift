////
//  FunctionTests.swift
//  
//  Created by Michel Tilman on 03/11/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import SwiftPuLP

/**
 Tests common functions.
 */
final class FunctionTests: XCTestCase {
    
    // MARK: Linear functions tests
    
    func testSumFunction() {
        let x = (0..<5).map { Variable("x_\($0)") }
        let sum = Function.sum(x)

        XCTAssertEqual(sum, x[0] + x[1] + x[2] + x[3] + x[4])
    }
    
}
