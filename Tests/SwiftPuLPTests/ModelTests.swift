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
        XCTAssertEqual(variable.domain, .continuous)
    }

    func testEmptyNameVariable() throws {
        let variable = Variable(name: "")
        
        XCTAssertNil(variable)
    }

    func testInvalidNameVariable() throws {
        let variable = Variable(name: "X Y Z")
        
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

}
