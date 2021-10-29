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
       
    func testVariable() throws {
        guard let variable = Variable("x", minimum: 1, maximum: 10, domain: .integer) else { return XCTFail("Nil variable") }
        
        XCTAssertEqual(variable.name, "x")
        XCTAssertEqual(variable.minimum, 1)
        XCTAssertEqual(variable.maximum, 10)
        XCTAssertEqual(variable.domain, .integer)
    }

    func testDefaultVariable() throws {
        guard let variable = Variable("x") else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.name, "x")
        XCTAssertNil(variable.minimum)
        XCTAssertNil(variable.maximum)
        XCTAssertEqual(variable.domain, .real)
    }

    func testEmptyNameVariable() throws {
        let variable = Variable("")
        
        XCTAssertNil(variable)
    }

    func testInvalidNameVariable() throws {
        for name in ("-+[] ->/".map { "x\($0)y" }) {
            XCTAssertNil(Variable(name))
        }
    }

    func testFixedVariable() throws {
        let variable = Variable("x", minimum: 1, maximum: 1, domain: .integer)
        
        XCTAssertNotNil(variable)
    }

    func testInvalidRangeVariable() throws {
        let variable = Variable("x", minimum: 3, maximum: 2, domain: .integer)
        
        XCTAssertNil(variable)
    }

    func testBinaryVariable() throws {
        guard let variable = Variable("x", minimum: 0, maximum: 1, domain: .binary) else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
        XCTAssertEqual(variable.domain, .binary)
    }

    func testDefaultBinaryVariable() throws {
        guard let variable = Variable("x", domain: .binary) else { return XCTFail("Nil variable") }

        XCTAssertEqual(variable.name, "x")
        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
    }

    func testInvalidMinimumBinaryVariable() throws {
        let variable = Variable("x", minimum: -1, domain: .binary)
        
        XCTAssertNil(variable)
    }

    func testInvalidMaximumBinaryVariable() throws {
        let variable = Variable("x", maximum: 2, domain: .binary)
        
        XCTAssertNil(variable)
    }
    
    // MARK: Conversion to PuLP tests
    
    func testVariableToPuLP() throws {
        guard let variable = Variable("x", minimum: 1, maximum: 10, domain: .integer) else { return XCTFail("Nil variable") }
        let pythonVariable = variable.pythonObject
        
        XCTAssertTrue(pythonVariable.isInstance(of: PuLP.LpVariable))
        XCTAssertEqual(pythonVariable.name, "x")
        XCTAssertEqual(pythonVariable.lowBound, 1)
        XCTAssertEqual(pythonVariable.upBound, 10)
        XCTAssertEqual(pythonVariable.cat, PuLP.LpInteger)
    }

    func testDefaultVariableToPuLP() throws {
        guard let variable = Variable("x") else { return XCTFail("Nil variable") }
        let pythonVariable = variable.pythonObject
        
        XCTAssertEqual(pythonVariable.name, "x")
        XCTAssertEqual(pythonVariable.lowBound, Python.None)
        XCTAssertEqual(pythonVariable.upBound, Python.None)
        XCTAssertEqual(pythonVariable.cat, PuLP.LpContinuous)
    }

    func testDomainToPuLP() throws {
        let domains = [Variable.Domain.binary, .real, .integer]
        let categories = [PuLP.LpBinary, PuLP.LpContinuous, PuLP.LpInteger]

        for (domain, category) in zip(domains, categories) {
            XCTAssertEqual(domain.pythonObject, category)
        }
    }

}