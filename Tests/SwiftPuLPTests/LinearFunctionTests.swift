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
        
    let pulp = Python.import("pulp")
    
    // MARK: Arithmetic operators tests
    
    func testFactorTimesVariable() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = 2 * x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 2)], constant: 0))
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
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 1)], constant: 0))
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
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: -1)], constant: 0))
    }
    
    func testVariableMinusFunction() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = x - (3 * y + 10)

        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: -3)], constant: -10))
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
        
        XCTAssertEqual(function, LinearFunction(terms: [], constant: 0))
    }
    
    func testMergeFactors() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = (2 * x) + (3 * y) - x
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)], constant: 0))
    }
    
    func testMergeAndFilterFactors() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = (2 * x) - (2 * x)
        
        XCTAssertEqual(function, LinearFunction(terms: [], constant: 0))
    }
    
    func testMergeSameVariables() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let z = x
        let function = (2 * x) + (3 * y) - z
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)], constant: 0))
    }
    
    func testMergeSameNameVariables() throws {
        guard let x = Variable("x"), let y = Variable("y"), let z = Variable("x", domain: .integer) else { return XCTFail("Nil variable") }
        let function = (2 * x) + (3 * y) - z
        
        XCTAssertEqual(function, LinearFunction(terms: [Term(variable: x, factor: 1), Term(variable: y, factor: 3)], constant: 0))
    }
    
    // MARK: Conversion to PuLP tests
    
    func testFunctionToAffineExpression() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = 2 * x + 3 * y + 10
        let affineExpression = function.pythonAffineExpression()

        XCTAssertTrue(affineExpression.isInstance(of: pulp.LpAffineExpression))
        XCTAssertEqual(affineExpression.toDict(), [["name": "x", "value": 2], ["name": "y", "value": 3]])
        XCTAssertEqual(affineExpression.constant, 10)
    }

    func testModelToPuLP() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = 2 * x + 3 * y + 10
        guard let model = Model("XYZ", objective: Objective(function, optimization: .maximize)) else { return XCTFail("Nil model") }
        let pythonModel = model.pythonObject
        
        XCTAssertTrue(pythonModel.isInstance(of: pulp.LpProblem))
        XCTAssertEqual(pythonModel.name, "XYZ")
        XCTAssertTrue(pythonModel.objective.isInstance(of: pulp.LpAffineExpression))
        XCTAssertEqual(pythonModel.objective.toDict(), [["name": "x", "value": 2], ["name": "y", "value": 3]])
        XCTAssertEqual(pythonModel.objective.constant, 10)
        XCTAssertEqual(pythonModel.sense, pulp.LpMaximize)
    }
    
}


/**
 Utility types.
 */
fileprivate typealias Term = LinearFunction.Term
