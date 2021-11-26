//
//  ModelTests.swift
//
//  Created by Michel Tilman on 22/10/2021.
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
 Tests creating a model.
 */
final class ModelTests: XCTestCase {
    
#if DEBUG

    // MARK: Model creation tests

    func testDefaultModel() {
        let model = Model("XYZ")
        
        XCTAssertNil(model.objective)
        XCTAssertEqual(model.optimization, .minimize)
        XCTAssertTrue(model.constraints.isEmpty)
    }

    func testModel() {
        let x = Variable("x")
        let model = Model("XYZ", objective: x)
        
        XCTAssertEqual(model.objective, +x)
    }

    func testVariableObjective() {
        let (x, y) = (Variable("x"), Variable("y"))
        let objective = 2 * x + y
        let constraints = [(x + y <= 10, "C1"), (3 * y >= 0, "C2")]
        let model = Model("XYZ", objective: objective, optimization: .maximize, constraints: constraints)
        
        XCTAssertEqual(model.objective, 2 * x + y)
        XCTAssertEqual(model.optimization, .maximize)
        XCTAssertTrue(model.constraints.elementsEqual(constraints, by: ==))
    }

    // MARK: Model variable tests

    func testVariables() {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("z"))
        let objective = 2 * x + z
        let constraints = [(x + y <= 10, "C1")]
        let model = Model("XYZ", objective: objective, constraints: constraints)
        
        XCTAssertTrue(model.variables.elementsEqual([x, z, y]))
    }

    func testDuplicateVariables() {
        let (x, y, z) = (Variable("x"), Variable("y"), Variable("x"))
        let objective = 2 * x + z
        let constraints = [(x + y <= 10, "C1")]
        let model = Model("XYZ", objective: objective, constraints: constraints)
        
        XCTAssertTrue(model.variables.elementsEqual([x, z, y]))
    }

    func testAliasedVariables() {
        let x = Variable("x")
        let y = x
        let objective = 2 * x + y
        let constraints = [(x + y <= 10, "C1")]
        let model = Model("XYZ", objective: objective, constraints: constraints)
        
        XCTAssertTrue(model.variables.elementsEqual([x]))
    }

#endif

}
