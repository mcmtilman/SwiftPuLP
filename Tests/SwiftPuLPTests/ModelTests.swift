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
 Tests creating and accessing a model.
 */
final class ModelTests: XCTestCase {
    
    let pulp = Python.import("pulp")
    
    // MARK: Variable tests
    
    func testVariable() throws {
        guard let variable = Variable("XYZ", minimum: 1, maximum: 10, domain: .integer) else { return XCTFail("Nil variable") }
        
        XCTAssertEqual(variable.name, "XYZ")
        XCTAssertEqual(variable.minimum, 1)
        XCTAssertEqual(variable.maximum, 10)
        XCTAssertEqual(variable.domain, .integer)
    }

    func testDefaultVariable() throws {
        guard let variable = Variable("XYZ") else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.name, "XYZ")
        XCTAssertNil(variable.minimum)
        XCTAssertNil(variable.maximum)
        XCTAssertEqual(variable.domain, .real)
    }

    func testEmptyNameVariable() throws {
        let variable = Variable("")
        
        XCTAssertNil(variable)
    }

    func testInvalidNameVariable() throws {
        let variable = Variable("X Y Z")
        
        XCTAssertNil(variable)
    }

    func testFixedVariable() throws {
        let variable = Variable("XYZ", minimum: 1, maximum: 1, domain: .integer)
        
        XCTAssertNotNil(variable)
    }

    func testInvalidRangeVariable() throws {
        let variable = Variable("XYZ", minimum: 3, maximum: 2, domain: .integer)
        
        XCTAssertNil(variable)
    }

    func testBinaryVariable() throws {
        guard let variable = Variable("XYZ", minimum: 0, maximum: 1, domain: .binary) else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
        XCTAssertEqual(variable.domain, .binary)
    }

    func testDefaultBinaryVariable() throws {
        guard let variable = Variable("XYZ", domain: .binary) else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.name, "XYZ")
        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
    }

    func testInvalidMinimumBinaryVariable() throws {
        let variable = Variable("XYZ", minimum: -1, domain: .binary)
        
        XCTAssertNil(variable)
    }

    func testInvalidMaximumBinaryVariable() throws {
        let variable = Variable("XYZ", maximum: 2, domain: .binary)
        
        XCTAssertNil(variable)
    }

    // MARK: Objective tests
    
    func testObjective() throws {
        guard let variable = Variable("X") else { return XCTFail("Nil variable") }
        let objective = Objective(variable, optimization: .minimize)

        XCTAssertEqual(objective.optimization, .minimize)
    }
    
    func testDefaultObjective() throws {
        guard let variable = Variable("X") else { return XCTFail("Nil variable") }
        let objective = Objective(variable)

        XCTAssertEqual(objective.optimization, .maximize)
    }
    
    // MARK: Model tests

    func testModel() throws {
        guard let variable = Variable("X") else { return XCTFail("Nil variable") }
        let model = Model("XYZ", objective: Objective(variable))
        
        XCTAssertNotNil(model)
    }

    func testEmptyNameModel() throws {
        guard let variable = Variable("X") else { return XCTFail("Nil variable") }
        let model = Model("", objective: Objective(variable))
        
        XCTAssertNil(model)
    }

    func testInvalidNameModel() throws {
        guard let variable = Variable("X") else { return XCTFail("Nil variable") }
        let model = Model("X Y Z", objective: Objective(variable))
        
        XCTAssertNil(model)
    }

    // MARK: Conversion to PuLP tests
    
    func testVariableToPuLP() throws {
        guard let variable = Variable("XYZ", minimum: 1, maximum: 10, domain: .integer) else { return XCTFail("Nil variable") }
        let pythonObject = variable.pythonObject
        
        XCTAssertEqual(Python.type(pythonObject), pulp.LpVariable)
        XCTAssertEqual(pythonObject.name, "XYZ")
        XCTAssertEqual(pythonObject.lowBound, 1)
        XCTAssertEqual(pythonObject.upBound, 10)
        XCTAssertEqual(pythonObject.cat, pulp.LpInteger)
    }

    func testDefaultVariableToPuLP() throws {
        guard let variable = Variable("XYZ") else { return XCTFail("Nil variable") }
        let pythonObject = variable.pythonObject
        
        XCTAssertEqual(pythonObject.name, "XYZ")
        XCTAssertEqual(pythonObject.lowBound, Python.None)
        XCTAssertEqual(pythonObject.upBound, Python.None)
        XCTAssertEqual(pythonObject.cat, pulp.LpContinuous)
    }

    func testDomainToPuLP() throws {
        let domains = [Variable.Domain.binary, .real, .integer]
        let categories = [pulp.LpBinary, pulp.LpContinuous, pulp.LpInteger]

        for (domain, category) in zip(domains, categories) {
            XCTAssertEqual(domain.pythonObject, category)
        }
    }

    func testOptimizationToPuLP() throws {
        let optimizations = [Objective.Optimization.maximize, .minimize]
        let senses = [pulp.LpMaximize, pulp.LpMinimize]

        for (optimization, sense) in zip(optimizations, senses) {
            XCTAssertEqual(optimization.pythonObject, sense)
        }
    }

    func testModelToPuLP() throws {
        guard let variable = Variable("X") else { return XCTFail("Nil variable") }
        guard let model = Model("XYZ", objective: Objective(variable)) else { return XCTFail("Nil model") }
        let pythonObject = model.pythonObject
        
        XCTAssertEqual(Python.type(pythonObject), pulp.LpProblem)
        XCTAssertEqual(pythonObject.name, "XYZ")
        XCTAssertEqual(pythonObject.sense, pulp.LpMaximize)
    }
}
