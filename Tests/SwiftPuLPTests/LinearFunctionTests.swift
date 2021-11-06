//
//  LinearFunctionTests.swift
//  
//  Created by Michel Tilman on 26/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import PythonKit
import SwiftPuLP

/**
 Tests building linear functions.
 */
final class LinearFunctionTests: XCTestCase {
        
    let PuLP = Python.import("pulp")
    
    // MARK: Linear function tests
    
    func testDefaultTermFactor() {
        let x = Variable("x")
        let term = Term(variable: x)
        
        XCTAssertEqual(term.factor, 1)
    }
    
    func testDefaultsFunction() {
        let function = LinearFunction()
        
        XCTAssertEqual(function.terms, [])
        XCTAssertEqual(function.constant, 0)
    }
    
    func testVariableAsFunction() {
        let x = Variable("x")
        let function = LinearFunction(variable: x)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x)]))
    }
    
    // MARK: Arithmetic operators tests
    
    func testPlusVariable() {
        let x = Variable("x")
        let function = +x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)]))
    }
    
    func testMinusVariable() {
        let x = Variable("x")
        let function = -x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: -1)]))
    }
    
   func testFactorTimesVariable() {
        let x = Variable("x")
        let function = 2 * x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)]))
    }
    
    func testFactorTimesFunction() {
        let x = Variable("x")
        let function = 4 * (2 * x + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 8)], constant: 40))
    }
    
    func testVariablePlusConstant() {
        let x = Variable("x")
        let function = x + 5
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)], constant: 5))
    }
    
    func testVariablePlusVariable() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x + y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 1)]))
    }
    
    func testVariablePlusFunction() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x + (3 * y + 10)

        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)], constant: 10))
    }
    
    func testVariableMinusConstant() {
        let x = Variable("x")
        let function = x - 5
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)], constant: -5))
    }
    
    func testVariableMinusVariable() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x - y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: -1)]))
    }
    
    func testVariableMinusFunction() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x - (3 * y + 10)

        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: -3)], constant: -10))
    }

    func testPlusFunction() {
        let x = Variable("x")
        let function = +(2 * x)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)]))
    }

    func testMinusFunction() {
        let x = Variable("x")
        let function = -(2 * x)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: -2)]))
    }
    
    func testFunctionPlusConstant() {
        let x = Variable("x")
        let function = (2 * x + 5) + 10
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)], constant: 15))
    }
    
    func testFunctionPlusVariable() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x + 5) + y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 1)], constant: 5))
    }
    
    func testFunctionPlusFunction() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x + 5) + (3 * y + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 3)], constant: 15))
    }
    
    func testFunctionMinusConstant() {
        let x = Variable("x")
        let function = (2 * x + 5) - 10
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)], constant: -5))
    }
    
    func testFunctionMinusVariable() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x + 5) - y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: -1)], constant: 5))
    }
    
    func testFunctionMinusFunction() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x + 5) - (3 * y + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: -3)], constant: -5))
    }
    
    func testParentheses() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 10 + 3 * y + 5
        
        XCTAssertEqual(function, (2 * x) + 10 + (3 * y) + 5)
        XCTAssertEqual(function, (2 * x + 10) + (3 * y + 5))
    }
    
    func testMultipleVariableSum() {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        let function = LinearFunction(terms: [Term(variable: x), Term(variable: y), Term(variable: z)])
        
        XCTAssertEqual(function, x + y + z)
    }
    
    // MARK: Normalizing linear function tests
    
    func testFilterZeroFactorVariable() {
        let x = Variable("x")
        let function = 0 * x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 0)]))
        XCTAssertEqual(function.normalized(), LinearFunction())
    }
    
    func testMergeFactors() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x) + (3 * y) - x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 3), Term(variable: x, factor: -1)]))
        XCTAssertEqual(function.normalized(), LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)]))
    }
    
    func testMergeAndFilterFactors() {
        let x = Variable("x")
        let function = (2 * x) - (2 * x)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: x, factor: -2)]))
        XCTAssertEqual(function.normalized(), LinearFunction())
    }
    
    func testMergeSameVariables() {
        let (x, y) = (Variable("x"), Variable("y"))
        let z = x
        let function = (2 * x) + (3 * y) - z
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 3), Term(variable: z, factor: -1)]))
        XCTAssertEqual(function.normalized(), LinearFunction(terms: [Term(variable: x), Term(variable: y, factor: 3)]))
    }
    
    func testMergeSameNameVariables() {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("x", domain: .integer))
        let function = (2 * x) + (3 * y) - z
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 3), Term(variable: z, factor: -1)]))
    }
    
    // Evaluation tests
    
    func testFunctionCall() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 3 * y + 10
        
        XCTAssertEqual(function(["x": 100, "y": 1000]), 3210)
    }
        
    // MARK: Conversion to PuLP tests
    
    func testFunctionToPuLP() {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 3 * y + 10
        let pythonObject = function.pythonObject

        XCTAssertTrue(pythonObject.isInstance(of: PuLP.LpAffineExpression))
        XCTAssertEqual(pythonObject.toDict(), [["name": "x", "value": 2], ["name": "y", "value": 3]])
        XCTAssertEqual(pythonObject.constant, 10)
    }

}


/**
 Utility types.
 */
fileprivate typealias Term = LinearFunction.Term
