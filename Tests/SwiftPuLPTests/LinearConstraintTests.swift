////
//  LinearConstraintTests.swift
//  
//  Created by Michel Tilman on 28/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import PythonKit
import SwiftPuLP

/**
 Tests building linear constraints.
 */
final class LinearConstraintTests: XCTestCase {

    let PuLP = Python.import("pulp")
    
    // MARK: Numeric comparison tests
    
    func testVariableLessThanConstraint() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let constraint = x <= 10
        guard let variable = constraint.function as? Variable else { return XCTFail("Expected objective function of type Variable")}
        
        XCTAssertEqual(variable, x)
        XCTAssertEqual(constraint.comparison, .lte)
        XCTAssertEqual(constraint.constant, 10)
    }
    
    func testVariableEqualToConstraint() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let constraint = x == 10
        guard let variable = constraint.function as? Variable else { return XCTFail("Expected objective function of type Variable")}
        
        XCTAssertEqual(variable, x)
        XCTAssertEqual(constraint.comparison, .eq)
        XCTAssertEqual(constraint.constant, 10)
    }
    
    func testVariableGreaterThanConstraint() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let constraint = x >= 10
        guard let variable = constraint.function as? Variable else { return XCTFail("Expected objective function of type Variable")}
        
        XCTAssertEqual(variable, x)
        XCTAssertEqual(constraint.comparison, .gte)
        XCTAssertEqual(constraint.constant, 10)
    }
    
}
