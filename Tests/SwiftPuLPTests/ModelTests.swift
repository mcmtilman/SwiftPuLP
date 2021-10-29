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
    
    func testVariableObjective() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let objective = Objective(x, optimization: .maximize)

        XCTAssertEqual(objective.function, x + 0)
        XCTAssertEqual(objective.optimization, .maximize)
    }
    
    func testFunctionObjective() throws {
        guard let x = Variable("x") else { return XCTFail("Nil variable") }
        let function = 2 * x + 1
        let objective = Objective(function, optimization: .maximize)

        XCTAssertEqual(objective.function, function)
        XCTAssertEqual(objective.optimization, .maximize)
    }
    
    func testDefaultObjective() throws {
        guard let variable = Variable("x") else { return XCTFail("Nil variable") }
        let objective = Objective(variable)

        XCTAssertEqual(objective.optimization, .minimize)
    }
    
    // MARK: Model tests

    func testModel() throws {
        guard let variable = Variable("x") else { return XCTFail("Nil variable") }
        let model = Model("XYZ", objective: Objective(variable))
        
        XCTAssertNotNil(model)
    }

    func testDefaultModel() throws {
        guard let model = Model("XYZ") else { return XCTFail("Nil variable") }
        
        XCTAssertNil(model.objective)
    }

    func testEmptyNameModel() throws {
        guard let variable = Variable("x") else { return XCTFail("Nil variable") }
        let model = Model("", objective: Objective(variable))
        
        XCTAssertNil(model)
    }

    func testInvalidNameModel() throws {
        guard let variable = Variable("x") else { return XCTFail("Nil variable") }
        
        XCTAssertNil(Model("X Z", objective: Objective(variable)))
    }

    // MARK: Conversion to PuLP tests
    
    func testOptimizationToPuLP() throws {
        let optimizations = [Objective.Optimization.maximize, .minimize]
        let senses = [PuLP.LpMaximize, PuLP.LpMinimize]

        for (optimization, sense) in zip(optimizations, senses) {
            XCTAssertEqual(optimization.pythonObject, sense)
        }
    }
    
    func testModelToPuLP() throws {
        guard let x = Variable("x"), let y = Variable("y") else { return XCTFail("Nil variable") }
        let function = 2 * x + 3 * y + 10
        guard let model = Model("XYZ", objective: Objective(function, optimization: .maximize)) else { return XCTFail("Nil model") }
        let pythonModel = model.pythonObject
        
        XCTAssertTrue(pythonModel.isInstance(of: PuLP.LpProblem))
        XCTAssertEqual(pythonModel.name, "XYZ")
        XCTAssertTrue(pythonModel.objective.isInstance(of: PuLP.LpAffineExpression))
        XCTAssertEqual(pythonModel.objective.toDict(), [["name": "x", "value": 2], ["name": "y", "value": 3]])
        XCTAssertEqual(pythonModel.objective.constant, 10)
        XCTAssertEqual(pythonModel.sense, PuLP.LpMaximize)
    }
    
   func testDefaultModelToPuLP() throws {
        guard let model = Model("XYZ") else { return XCTFail("Nil model") }
        let pythonModel = model.pythonObject
        
        XCTAssertTrue(pythonModel.objective.isNone)
        XCTAssertEqual(pythonModel.sense, PuLP.LpMinimize)
    }
    
}
