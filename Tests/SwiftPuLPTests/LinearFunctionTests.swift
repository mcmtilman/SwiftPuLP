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
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = LinearFunction(variable: x)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)], constant: 0))
    }
    
    // MARK: Arithmetic operators tests
    
    func testMinusVariable() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = -1 * x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: -1)]))
    }
    
   func testFactorTimesVariable() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = 2 * x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)]))
    }
    
    func testFactorTimesFunction() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = 4 * (2 * x + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 8)], constant: 40))
    }
    
    func testVariablePlusConstant() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = x + 5
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)], constant: 5))
    }
    
    func testVariablePlusVariable() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = x + y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 1)]))
    }
    
    func testVariablePlusFunction() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = x + (3 * y + 10)

        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)], constant: 10))
    }
    
    func testVariableMinusConstant() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = x - 5
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1)], constant: -5))
    }
    
    func testVariableMinusVariable() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = x - y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: -1)]))
    }
    
    func testVariableMinusFunction() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = x - (3 * y + 10)

        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: -3)], constant: -10))
    }

    func testMinusFunction() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = 2 * x
        
        XCTAssertEqual(-function, LinearFunction(terms: [Term(variable: x, factor: -2)]))
    }
    
    func testFunctionPlusConstant() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = (2 * x + 5) + 10
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)], constant: 15))
    }
    
    func testFunctionPlusVariable() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = (2 * x + 5) + y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 1)], constant: 5))
    }
    
    func testFunctionPlusFunction() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = (2 * x + 5) + (3 * y + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 3)], constant: 15))
    }
    
    func testFunctionMinusConstant() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = (2 * x + 5) - 10
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)], constant: -5))
    }
    
    func testFunctionMinusVariable() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = (2 * x + 5) - y
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: -1)], constant: 5))
    }
    
    func testFunctionMinusFunction() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = (2 * x + 5) - (3 * y + 10)
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: -3)], constant: -5))
    }
    
    func testParentheses() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = 2 * x + 10 + 3 * y + 5
        
        XCTAssertEqual(function, (2 * x) + 10 + (3 * y) + 5)
        XCTAssertEqual(function, (2 * x + 10) + (3 * y + 5))
    }
    
    // MARK: Filtering and merging terms tests
    
    func testFilterZeroFactorVariable() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = 0 * x
        
        XCTAssertEqual(function, LinearFunction(terms: []))
    }
    
    func testMergeFactors() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = (2 * x) + (3 * y) - x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)]))
    }
    
    func testMergeAndFilterFactors() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = (2 * x) - (2 * x)
        
        XCTAssertEqual(function, LinearFunction(terms: []))
    }
    
    func testMergeSameVariables() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let z = x
        let function = (2 * x) + (3 * y) - z
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x), Term(variable: y, factor: 3)]))
    }
    
    func testMergeSameNameVariables() throws {
        guard let x = Variable("x"), let y = Variable("y"), let z = Variable("x", domain: .integer) else { return XCTFail("Nil variable") }
        let function = (2 * x) + (3 * y) - z
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2), Term(variable: y, factor: 3), Term(variable: z, factor: -1)]))
    }
    
    // Evaluation tests
    
    func testFunctionCall() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = 2 * x + 3 * y + 10
        
        XCTAssertEqual(function(["x": 100, "y": 1000]), 3210)
    }
        
    // MARK: Conversion to PuLP tests
    
    func testFunctionToPuLP() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
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
