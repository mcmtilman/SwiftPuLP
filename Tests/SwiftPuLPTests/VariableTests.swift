////
//  VariableTests.swift
//  
//  Created by Michel Tilman on 29/10/2021.
//  Copyright © 2021 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest

#if DEBUG
    @testable import SwiftPuLP
#else
    import SwiftPuLP
#endif

/**
 Tests creating a variable.
 */
final class VariableTests: XCTestCase {
    
#if DEBUG
    
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

    func testDefaultBinaryVariable() {
        let variable = Variable("x", domain: .binary)

        XCTAssertEqual(variable.name, "x")
        XCTAssertEqual(variable.minimum, 0)
        XCTAssertEqual(variable.maximum, 1)
    }
    
    // MARK: Invalid variable tests
       
    func testInvalidVariable() {
        let variable = Variable("x y", minimum: 3, maximum: 1, domain: .integer)
        
        XCTAssertEqual(variable.name, "x y")
        XCTAssertEqual(variable.minimum, 3)
        XCTAssertEqual(variable.maximum, 1)
        XCTAssertEqual(variable.domain, .integer)
    }

    func testInvalidBinaryVariable() {
        let variable = Variable("x", minimum: -1, maximum: 2, domain: .binary)
        
        XCTAssertEqual(variable.name, "x")
        XCTAssertEqual(variable.minimum, -1)
        XCTAssertEqual(variable.maximum, 2)
        XCTAssertEqual(variable.domain, .binary)
    }

#endif

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
