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
    
    let pulpModule = Python.import("pulp")
    
    // MARK: Variable tests
    
    func testVariable() throws {
        guard let variable = Variable(name: "XYZ", minimum: 1, maximum: 10, domain: .integer) else { return XCTFail("Nil variable") }
        
        XCTAssertEqual(variable.name, "XYZ")
        XCTAssertEqual(variable.minimum, 1)
        XCTAssertEqual(variable.maximum, 10)
        XCTAssertEqual(variable.domain, .integer)
    }

    func testDefaultVariable() throws {
        guard let variable = Variable(name: "XYZ") else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.name, "XYZ")
        XCTAssertNil(variable.minimum)
        XCTAssertNil(variable.maximum)
        XCTAssertEqual(variable.domain, .real)
    }

    func testEmptyNameVariable() throws {
        let variable = Variable(name: "")
        
        XCTAssertNil(variable)
    }

    func testInvalidNameVariable() throws {
        let variable = Variable(name: "X Y Z")
        
        XCTAssertNil(variable)
    }

    func testFixedVariable() throws {
        let variable = Variable(name: "XYZ", minimum: 1, maximum: 1, domain: .integer)
        
        XCTAssertNotNil(variable)
    }

    func testInvalidRangeVariable() throws {
        let variable = Variable(name: "XYZ", minimum: 3, maximum: 2, domain: .integer)
        
        XCTAssertNil(variable)
    }

    func testBinaryVariable() throws {
        guard let variable = Variable(name: "XYZ", minimum: 0, maximum: 1, domain: .binary) else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
        XCTAssertEqual(variable.domain, .binary)
    }

    func testDefaultBinaryVariable() throws {
        guard let variable = Variable(name: "XYZ", domain: .binary) else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.name, "XYZ")
        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
    }

    func testInvalidMinimumBinaryVariable() throws {
        let variable = Variable(name: "XYZ", minimum: -1, domain: .binary)
        
        XCTAssertNil(variable)
    }

    func testInvalidMaximumBinaryVariable() throws {
        let variable = Variable(name: "XYZ", maximum: 2, domain: .binary)
        
        XCTAssertNil(variable)
    }

    // MARK: Objective tests
    
    func testObjective() throws {
        guard let variable = Variable(name: "X") else { return XCTFail("Nil variable") }
        let objective = Objective(expression: variable, optimization: .minimize)

        XCTAssertEqual(objective.optimization, .minimize)
    }
    
    func testDefaultObjective() throws {
        guard let variable = Variable(name: "X") else { return XCTFail("Nil variable") }
        let objective = Objective(expression: variable)

        XCTAssertEqual(objective.optimization, .maximize)
    }
    
    // MARK: Conversion to PuLP tests
    
    func testDomainToPython() throws {
        let domains: [Variable.Domain] = [.binary, .real, .integer]
        let pythonObjects = [pulpModule.LpBinary, pulpModule.LpContinuous, pulpModule.LpInteger]

        for (domain, pythonObject) in zip(domains, pythonObjects) {
            XCTAssertEqual(domain.pythonObject, pythonObject)
        }
    }

    func testVariableToPython() throws {
        guard let variable = Variable(name: "XYZ", minimum: 1, maximum: 10, domain: .integer) else { return XCTFail("Nil variable") }
        let pythonObject = variable.pythonObject
        
        XCTAssertEqual(pythonObject.name, "XYZ")
        XCTAssertEqual(pythonObject.lowBound, 1)
        XCTAssertEqual(pythonObject.upBound, 10)
        XCTAssertEqual(pythonObject.cat, pulpModule.LpInteger)
    }

    func testDefaultVariableToPython() throws {
        guard let variable = Variable(name: "XYZ") else { return XCTFail("Nil variable") }
        let pythonObject = variable.pythonObject
        
        XCTAssertEqual(pythonObject.name, "XYZ")
        XCTAssertEqual(pythonObject.lowBound, Python.None)
        XCTAssertEqual(pythonObject.upBound, Python.None)
        XCTAssertEqual(pythonObject.cat, pulpModule.LpContinuous)
    }

    func testOptimizationToPython() throws {
        let optimizations: [Objective.Optimization] = [.maximize, .minimize]
        let pythonObjects = [pulpModule.LpMaximize, pulpModule.LpMinimize]

        for (optimization, pythonObject) in zip(optimizations, pythonObjects) {
            XCTAssertEqual(optimization.pythonObject, pythonObject)
        }
    }

}
