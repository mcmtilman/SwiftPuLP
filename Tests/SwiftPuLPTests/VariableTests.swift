////
//  VariableTests.swift
//  
//  Created by Michel Tilman on 29/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
import PythonKit
import SwiftPuLP

/**
 Tests creating and converting a variable.
 */
final class VariableTests: XCTestCase {
    
    let PuLP = Python.import("pulp")
    
    // MARK: Variable tests
       
    func testVariable() {
        let variable = Variable("x", minimum: 1, maximum: 10, domain: .integer)
        
        XCTAssertEqual(variable.name, "x")
        XCTAssertEqual(variable.minimum, 1)
        XCTAssertEqual(variable.maximum, 10)
        XCTAssertEqual(variable.domain, .integer)
    }

    func testDefaultVariable() {
        let variable = Variable("x")

        XCTAssertEqual(variable.name, "x")
        XCTAssertNil(variable.minimum)
        XCTAssertNil(variable.maximum)
        XCTAssertEqual(variable.domain, .real)
    }

    func testBinaryVariable() {
        let variable = Variable("x", minimum: 0, maximum: 1, domain: .binary)

        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
        XCTAssertEqual(variable.domain, .binary)
    }

    func testDefaultBinaryVariable() {
        let variable = Variable("x", domain: .binary)

        XCTAssertEqual(variable.name, "x")
        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
    }
    
    // MARK: Conversion to PuLP tests
    
    func testVariableToPuLP() {
        let variable = Variable("x", minimum: 1, maximum: 10, domain: .integer)
        let pythonVariable = variable.pythonObject
        
        XCTAssertTrue(pythonVariable.isInstance(of: PuLP.LpVariable))
        XCTAssertEqual(pythonVariable.name, "x")
        XCTAssertEqual(pythonVariable.lowBound, 1)
        XCTAssertEqual(pythonVariable.upBound, 10)
        XCTAssertEqual(pythonVariable.cat, PuLP.LpInteger)
    }

    func testDefaultVariableToPuLP() {
        let variable = Variable("x")
        let pythonVariable = variable.pythonObject
        
        XCTAssertEqual(pythonVariable.name, "x")
        XCTAssertEqual(pythonVariable.lowBound, Python.None)
        XCTAssertEqual(pythonVariable.upBound, Python.None)
        XCTAssertEqual(pythonVariable.cat, PuLP.LpContinuous)
    }

    func testDomainToPuLP() {
        let domains = [Variable.Domain.binary, .real, .integer]
        let categories = [PuLP.LpBinary, PuLP.LpContinuous, PuLP.LpInteger]

        for (domain, category) in zip(domains, categories) {
            XCTAssertEqual(domain.pythonObject, category)
        }
    }

    // MARK: Variable cache tests
    
    func testUncachedVariables() {
        let variables = [Variable("x"), Variable("y"), Variable("x" )]
        let ids = variables.map(\.pythonObject.id)

        XCTAssertEqual(Set(ids).count, 1)
    }

    func testRetainUncachedVariables() {
        let variables = [Variable("x"), Variable("y"), Variable("x" )]
        let pythonObjects = variables.map(\.pythonObject) // Needed
        let ids = pythonObjects.map(\.id)

        XCTAssertEqual(Set(ids).count, 3)
    }

}
