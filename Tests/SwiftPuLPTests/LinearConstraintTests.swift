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
    
    // MARK: Comparison tests
    
    func testVariableLessThanConstraint() {
        let x = Variable("x")
        let constraint = x <= 5
        
        XCTAssertEqual(constraint.function, LinearFunction(variable: x))
        XCTAssertEqual(constraint.comparison, .lte)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testVariableEqualToConstraint() {
        let x = Variable("x")
        let constraint = x == 5
        
        XCTAssertEqual(constraint.function, LinearFunction(variable: x))
        XCTAssertEqual(constraint.comparison, .eq)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testVariableGreaterThanConstraint() {
        let x = Variable("x")
        let constraint = x >= 5
        
        XCTAssertEqual(constraint.function, LinearFunction(variable: x))
        XCTAssertEqual(constraint.comparison, .gte)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testFunctionLessThanConstraint() {
        let (x, y) = (Variable("x"), Variable("y"))
        let constraint = 2 * x + 3 * y + 10 <= 5
        
        XCTAssertEqual(constraint.function, 2 * x + 3 * y + 10)
        XCTAssertEqual(constraint.comparison, .lte)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testFunctionEqualToConstraint() {
        let (x, y) = (Variable("x"), Variable("y"))
        let constraint = 2 * x + 3 * y + 10 == 5
        
        XCTAssertEqual(constraint.function, 2 * x + 3 * y + 10)
        XCTAssertEqual(constraint.comparison, .eq)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testFunctionGreaterThanConstraint() {
        let (x, y) = (Variable("x"), Variable("y"))
        let constraint = 2 * x + 3 * y + 10 >= 5
        
        XCTAssertEqual(constraint.function, 2 * x + 3 * y + 10)
        XCTAssertEqual(constraint.comparison, .gte)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    // Evaluation tests
    
    func testCompareFunctionCall() {
        let (x, y) = (Variable("x"), Variable("y"))
        let constraints = [
            2 * x + 3 * y + 9 <= 3210,
            2 * x + 3 * y + 10 == 3210,
            2 * x + 3 * y + 11 >= 3210
        ]
        
        for constraint in constraints {
            XCTAssertTrue(constraint(["x": 100, "y": 1000]))
        }
    }
        
    // MARK: Conversion to PuLP tests
    
    func testConstraintToPuLP() {
        let (x, y) = (Variable("x"), Variable("y"))
        let constraint = 2 * x + 3 * y <= 5
        let pythonConstraint = constraint.pythonObject

        XCTAssertTrue(pythonConstraint.isInstance(of: PuLP.LpConstraint))
        XCTAssertEqual(pythonConstraint.toDict()["coefficients"], [["name": "x", "value": 2], ["name": "y", "value": 3]])
        // PuLP internally transforms the constraint into 2 * x + 3 * y - 5 <= 0.
        // The PuLP constant retrieved from LpConstraint is actually the constant of the
        // transformed linear function, hence -5.
        XCTAssertEqual(pythonConstraint.constant, -5)
        XCTAssertEqual(pythonConstraint.sense, PuLP.LpConstraintLE)
    }

    func testComparisonToPuLP() {
        let comparisons = [LinearConstraint.Comparison.lte, .eq, .gte]
        let senses = [PuLP.LpConstraintLE, PuLP.LpConstraintEQ, PuLP.LpConstraintGE]

        for (comparison, sense) in zip(comparisons, senses) {
            XCTAssertEqual(comparison.pythonObject, sense)
        }
    }

}
