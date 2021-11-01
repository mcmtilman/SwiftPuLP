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
    
    // MARK: Variable as function tests
    
    func testVariableAsFunction() throws {
        let x = Variable("x")
        let function = LinearFunction(variable: x)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)], constant: 0))
    }
    
    // MARK: Arithmetic operators tests
    
    func testMinusVariable() throws {
        let x = Variable("x")
        let function = -1 * x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: -1)]))
    }
    
   func testFactorTimesVariable() throws {
        let x = Variable("x")
        let function = 2 * x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)]))
    }
    
    func testFactorTimesFunction() throws {
        let x = Variable("x")
        let function = 4 * (2 * x + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 8)], constant: 40))
    }
    
    func testVariablePlusConstant() throws {
        let x = Variable("x")
        let function = x + 5
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)], constant: 5))
    }
    
    func testVariablePlusVariable() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x + y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 1)]))
    }
    
    func testVariablePlusFunction() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x + (3 * y + 10)

        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)], constant: 10))
    }
    
    func testVariableMinusConstant() throws {
        let x = Variable("x")
        let function = x - 5
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)], constant: -5))
    }
    
    func testVariableMinusVariable() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x - y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: -1)]))
    }
    
    func testVariableMinusFunction() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = x - (3 * y + 10)

        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: -3)], constant: -10))
    }

    func testMinusFunction() throws {
        let x = Variable("x")
        let function = 2 * x
        
        XCTAssertEqual(-function, LinearFunction(terms: [Term(variable: x, factor: -2)]))
    }
    
    func testFunctionPlusConstant() throws {
        let x = Variable("x")
        let function = (2 * x + 5) + 10
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)], constant: 15))
    }
    
    func testFunctionPlusVariable() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x + 5) + y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 1)], constant: 5))
    }
    
    func testFunctionPlusFunction() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x + 5) + (3 * y + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 3)], constant: 15))
    }
    
    func testFunctionMinusConstant() throws {
        let x = Variable("x")
        let function = (2 * x + 5) - 10
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)], constant: -5))
    }
    
    func testFunctionMinusVariable() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x + 5) - y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: -1)], constant: 5))
    }
    
    func testFunctionMinusFunction() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x + 5) - (3 * y + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: -3)], constant: -5))
    }
    
    func testParentheses() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 10 + 3 * y + 5
        
        XCTAssertEqual(function, (2 * x) + 10 + (3 * y) + 5)
        XCTAssertEqual(function, (2 * x + 10) + (3 * y + 5))
    }
    
    // MARK: Filtering and merging terms tests
    
    func testFilterZeroFactorVariable() throws {
        let x = Variable("x")
        let function = 0 * x
        
        XCTAssertEqual(function, LinearFunction(terms: []))
    }
    
    func testMergeFactors() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = (2 * x) + (3 * y) - x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)]))
    }
    
    func testMergeAndFilterFactors() throws {
        let x = Variable("x")
        let function = (2 * x) - (2 * x)
        
        XCTAssertEqual(function, LinearFunction(terms: []))
    }
    
    func testMergeSameVariables() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let z = x
        let function = (2 * x) + (3 * y) - z
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x), Term(variable: y, factor: 3)]))
    }
    
    func testMergeSameNameVariables() throws {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("x", domain: .integer))
        let function = (2 * x) + (3 * y) - z
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 3), Term(variable: z, factor: -1)]))
    }
    
    // Evaluation tests
    
    func testFunctionCall() throws {
        let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 3 * y + 10
        
        XCTAssertEqual(function(["x": 100, "y": 1000]), 3210)
    }
        
    // MARK: Conversion to PuLP tests
    
    func testFunctionToPuLP() throws {
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
