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
    
    func testVariableLessThanConstraint() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let constraint = x <= 5
        
        XCTAssertEqual(constraint.function, LinearFunction(variable: x))
        XCTAssertEqual(constraint.comparison, .lte)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testVariableEqualToConstraint() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let constraint = x == 5
        
        XCTAssertEqual(constraint.function, LinearFunction(variable: x))
        XCTAssertEqual(constraint.comparison, .eq)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testVariableGreaterThanConstraint() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let constraint = x >= 5
        
        XCTAssertEqual(constraint.function, LinearFunction(variable: x))
        XCTAssertEqual(constraint.comparison, .gte)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testFunctionLessThanConstraint() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let constraint = 2 * x + 3 * y + 10 <= 5
        
        XCTAssertEqual(constraint.function, 2 * x + 3 * y + 10)
        XCTAssertEqual(constraint.comparison, .lte)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testFunctionEqualToConstraint() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let constraint = 2 * x + 3 * y + 10 == 5
        
        XCTAssertEqual(constraint.function, 2 * x + 3 * y + 10)
        XCTAssertEqual(constraint.comparison, .eq)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    func testFunctionGreaterThanConstraint() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let constraint = 2 * x + 3 * y + 10 >= 5
        
        XCTAssertEqual(constraint.function, 2 * x + 3 * y + 10)
        XCTAssertEqual(constraint.comparison, .gte)
        XCTAssertEqual(constraint.constant, 5)
    }
    
    // Evaluation tests
    
    func testCompareFunctionCall() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
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
    
    func testConstraintToPuLP() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
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

    func testComparisonToPuLP() throws {
        let comparisons = [LinearConstraint.Comparison.lte, .eq, .gte]
        let senses = [PuLP.LpConstraintLE, PuLP.LpConstraintEQ, PuLP.LpConstraintGE]

        for (comparison, sense) in zip(comparisons, senses) {
            XCTAssertEqual(comparison.pythonObject, sense)
        }
    }

}
