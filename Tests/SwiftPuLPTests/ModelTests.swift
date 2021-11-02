//
//  ModelTests.swift
//
//  Created by Michel Tilman on 22/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import PythonKit
import SwiftPuLP

/**
 Tests creating and converting a model.
 */
final class ModelTests: XCTestCase {
    
    let PuLP = Python.import("pulp")
    
    // MARK: Objective tests
    
    func testVariableObjective() {
        let x = Variable("x")
        let objective = Objective(x, optimization: .maximize)

        XCTAssertEqual(objective.function, x + 0)
        XCTAssertEqual(objective.optimization, .maximize)
    }
    
    func testFunctionObjective() {
        let x = Variable("x")
        let function = 2 * x + 1
        let objective = Objective(function, optimization: .maximize)

        XCTAssertEqual(objective.function, function)
        XCTAssertEqual(objective.optimization, .maximize)
    }
    
    func testDefaultObjective() {
        let x = Variable("x")
        let objective = Objective(x)

        XCTAssertEqual(objective.optimization, .minimize)
    }
    
    // MARK: Model tests

    func testModel() {
        let x = Variable("x")
        let model = Model("XYZ", objective: Objective(x))
        
        XCTAssertNotNil(model)
    }

    func testDefaultModel() {
        let model = Model("XYZ")
        
        XCTAssertNil(model.objective)
    }

    // MARK: Conversion to PuLP tests
    
    func testOptimizationToPuLP() {
        let optimizations = [Model.Optimization.maximize, .minimize]
        let senses = [PuLP.LpMaximize, PuLP.LpMinimize]

        for (optimization, sense) in zip(optimizations, senses) {
            XCTAssertEqual(optimization.pythonObject, sense)
        }
    }
    
    func testModelToPuLP() {
       let (x, y) = (Variable("x"), Variable("y"))
        let function = 2 * x + 3 * y + 10
        let model = Model("XYZ", objective: Objective(function, optimization: .maximize))
        let pythonModel = model.pythonObject
        
        XCTAssertTrue(pythonModel.isInstance(of: PuLP.LpProblem))
        XCTAssertEqual(pythonModel.name, "XYZ")
        XCTAssertTrue(pythonModel.objective.isInstance(of: PuLP.LpAffineExpression))
        XCTAssertEqual(pythonModel.objective.toDict(), [["name": "x", "value": 2], ["name": "y", "value": 3]])
        XCTAssertEqual(pythonModel.objective.constant, 10)
        XCTAssertEqual(pythonModel.sense, PuLP.LpMaximize)
    }
    
   func testDefaultModelToPuLP() {
        let model = Model("XYZ")
        let pythonModel = model.pythonObject
        
        XCTAssertTrue(pythonModel.objective.isNone)
        XCTAssertEqual(pythonModel.sense, PuLP.LpMinimize)
    }
    
}


/**
 Utility types.
 */
fileprivate typealias Objective = Model.Objective
